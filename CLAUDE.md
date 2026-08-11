# Containers Repo

Container image monorepo. Each app lives in `apps/<name>/` with a Dockerfile, docker-bake.hcl, entrypoint.sh, and container_test.go.

## Architecture

- `apps/` — per-app container image definitions
- `skel/alpine/` — skeleton template for Alpine-based apps (catatonit init, apk packages)
- `skel/distroless/` — skeleton template for distroless apps (multi-stage, static binaries)
- `include/` — shared files (`.dockerignore`) rsync'd into each app at build time
- `testhelpers/` — shared Go test utilities using testcontainers-go
- `.github/actions/` — reusable composite actions for app lifecycle
- `.github/workflows/` — CI/CD pipelines

## Per-App Structure

```
apps/<name>/
  Dockerfile           # image build
  docker-bake.hcl      # version, source, platforms (Renovate reads this)
  entrypoint.sh        # startup script (Alpine only)
  container_test.go    # Go integration test
```

## Adding a New App

Copy from `skel/alpine` or `skel/distroless`, replace all `CHANGEME` placeholders. See CONTRIBUTING.md for full instructions.

## Conventions

- All images run as `nobody:nogroup` (UID 65534)
- Alpine images use `catatonit` as init; distroless images don't need it
- Persistent data at `/config`
- Platforms: `linux/amd64` + `linux/arm64`
- Registry: `ghcr.io/swagner-de/containers/<app-name>`
- Versions tracked via Renovate annotations in `docker-bake.hcl`

## Image Tags

Published on release (push to main):

- `X.Y.Z`, `X.Y`, `X` — **immutable** semver tags, published only on the *first*
  build of a version (when the build revision is 0). Never overwritten by later
  rebuilds, so a pinned `X.Y.Z` digest is stable.
- `X.Y.Z-bN` — **build revision**. `N` auto-increments on every rebuild of the
  same app version (Dockerfile/dep changes). Human-orderable; use this to pin a
  specific rebuild. (The `-b` suffix avoids colliding with Alpine's `-rN`
  package-release suffix seen in dynamic versions like `4.23.8-r0`.)
- `X.Y.Z-g<sha>` — build keyed by commit SHA.
- `rolling` — always the latest build.
- `sandbox` — PR builds (not released).

The build revision `N` is derived from git in `.github/scripts/app-build.sh`:
the count of build-affecting commits (`Dockerfile`, `entrypoint.sh`,
`docker-bake.hcl`, `resolve-version.sh`) since the commit that last changed the
app's version. For static-version apps the version anchor is the `VERSION` line
in `docker-bake.hcl`; for dynamic-version apps (empty `VERSION` +
`resolve-version.sh`) it is the `FROM` line in the `Dockerfile`. Test- and
doc-only changes do not advance the revision. This requires full git history, so
jobs running the script use `fetch-depth: 0`.

Dynamic-version apps (e.g. samba) carry the full upstream string — including
Alpine's `-rN` package-release suffix — in their immutable and revision tags
(e.g. `4.23.8-r0`, `4.23.8-r0-b1`). The git counter cannot see an apk-only bump
(`r0` → `r1`) because it does not touch a build-affecting file, so the `-rN`
component is the discriminator that keeps those tags unique. For this reason
dynamic apps always publish the full-version tag on release (not gated on the
first build).

## Workflows

- **release.yaml** — push to main triggers build + push to GHCR
- **pull-request.yaml** — PR triggers build + test (sandbox tag)
- **app-builder.yaml** — reusable: plan → build → merge manifest → SBOM + attestation
- **vulnerability-scan.yaml** — daily Grype scan, SARIF to GitHub Security tab
- **readme-gen.yaml** — auto-generates per-app and root READMEs

## Testing

```bash
cd apps/<name>
VERSION=$(../../.github/scripts/app-version.sh .)
docker buildx bake image-local
TEST_IMAGE="<name>:${VERSION}" go test -v ./...
```

`app-version.sh` resolves an app's `VERSION` — bake's default when set, otherwise the output of the app's `resolve-version.sh` (used for apps whose version tracks a base-image package; see CONTRIBUTING.md).

## Commit Style

Use conventional commits: `feat:`, `fix:`, `docs:`, `release(<app>):` for version bumps.
