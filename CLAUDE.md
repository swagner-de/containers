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

## Workflows

- **release.yaml** — push to main triggers build + push to GHCR
- **pull-request.yaml** — PR triggers build + test (sandbox tag)
- **app-builder.yaml** — reusable: plan → build → merge manifest → SBOM + attestation
- **vulnerability-scan.yaml** — daily Grype scan, SARIF to GitHub Security tab
- **readme-gen.yaml** — auto-generates per-app and root READMEs

## Testing

```bash
cd apps/<name>
docker buildx bake image-local
TEST_IMAGE="<name>:<version>" go test -v ./...
```

## Commit Style

Use conventional commits: `feat:`, `fix:`, `docs:`, `release(<app>):` for version bumps.
