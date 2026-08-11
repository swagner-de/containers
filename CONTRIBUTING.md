# Contributing

## Adding a new app

1. Copy the appropriate skeleton:

   ```bash
   # For apps needing Alpine (package manager, shell, runtime deps):
   cp -r skel/alpine apps/<app-name>

   # For static binaries (Go, Rust):
   cp -r skel/distroless apps/<app-name>
   ```

2. Edit `apps/<app-name>/docker-bake.hcl`:
   - Set `APP` to the app name
   - Set `VERSION` with a Renovate annotation for automatic updates
   - Set `SOURCE` to the upstream repo URL

3. Edit `apps/<app-name>/Dockerfile`:
   - Install the application
   - Keep the image rootless (`USER nobody:nogroup`)

4. Edit `apps/<app-name>/entrypoint.sh` (Alpine only):
   - Configure how the app starts

5. Edit `apps/<app-name>/container_test.go`:
   - Update the image name and port
   - Add any app-specific health checks

6. Test locally:

   ```bash
   cd apps/<app-name>
   VERSION=$(../../.github/scripts/app-version.sh .) docker buildx bake image-local
   ```

   `app-version.sh` returns the app's `VERSION` — bake's default when set, or the output of the app's `resolve-version.sh` when the version is resolved dynamically (see below).

7. Open a PR. CI will build the image and run tests.

## Conventions

- **Rootless**: All images run as `nobody:nogroup` (UID 65534)
- **Init**: Use `catatonit` on Alpine images. Distroless images don't need it.
- **Volume**: Mount persistent data at `/config`
- **Platforms**: `linux/amd64` + `linux/arm64` by default

## Renovate annotations

Version tracking in `docker-bake.hcl`:

```hcl
variable "VERSION" {
  // renovate: datasource=github-releases depName=org/repo
  default = "1.2.3"
}
```

Dependency tracking in `Dockerfile`:

```dockerfile
# renovate: datasource=github-releases depName=org/repo
ARG DEPENDENCY_VERSION=1.2.3
```

## Dynamic version resolution

For apps whose version is coupled to a base image (e.g. an Alpine package where the available version depends on the `FROM alpine:X.Y` tag), pinning both would require Renovate to bump them atomically, which it does not support. Instead:

- Leave `VERSION` in `docker-bake.hcl` with an empty default:

  ```hcl
  variable "VERSION" {
    default = ""
  }
  ```

- Do not pin the package in the `Dockerfile`. Let `apk add <pkg>` install whatever the base image currently ships.
- Add an executable `resolve-version.sh` in the app dir that prints the resolved version to stdout. It runs in CI and locally when `VERSION` is empty. Example: `apps/samba/resolve-version.sh` queries `apk info samba-server` against the Dockerfile's Alpine tag.

The resulting image tag reflects whatever was installed at build time. Renovate PRs on the base image now build green without needing a coupled package bump.

## Build revisions

Images are tagged `X.Y.Z-bN`, where `N` is a build revision that increments
automatically each time an app is rebuilt without an upstream version change
(e.g. a Dockerfile edit or a dependency bump). The bare `X.Y.Z` tag is
immutable — it is published only on the first build (`-b0`) of a version and is
never overwritten, so consumers pinned to `X.Y.Z` never silently receive a
rebuild.

You do **not** manage the revision manually. It is derived from git history by
`.github/scripts/app-build.sh` (commits touching build-affecting files since the
version last changed). A version bump resets it to `-b0`; a later dep/Dockerfile
change produces `-b1`, `-b2`, and so on. Changes to tests or READMEs do not bump
it.

Dynamic-version apps (those using `resolve-version.sh`, like samba) keep the
full upstream string — including Alpine's `-rN` package-release suffix — in
their tags (e.g. `4.23.8-r0-b1`), since that suffix distinguishes apk-only
rebuilds the git counter cannot see.

## Testing

Tests use [testcontainers-go](https://golang.testcontainers.org/). Each app has a `container_test.go` that spins up the built image and verifies it works.

Run tests locally:

```bash
cd apps/<app-name>
VERSION=$(../../.github/scripts/app-version.sh .)
docker buildx bake image-local
TEST_IMAGE="<app-name>:${VERSION}" go test -v ./...
```
