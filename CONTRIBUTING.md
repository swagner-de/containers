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
   docker buildx bake image-local
   ```

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

## Testing

Tests use [testcontainers-go](https://golang.testcontainers.org/). Each app has a `container_test.go` that spins up the built image and verifies it works.

Run tests locally:

```bash
cd apps/<app-name>
docker buildx bake image-local
TEST_IMAGE="<app-name>:<version>" go test -v ./...
```
