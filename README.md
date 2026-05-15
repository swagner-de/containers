# Containers

Container images built and published to GHCR.

## Images

All images are:
- Rootless — running as `nobody:nogroup` (UID 65534)
- Multi-arch — `linux/amd64` and `linux/arm64`
- Scanned daily for vulnerabilities
- Signed with GitHub attestations

## Usage

```bash
docker pull ghcr.io/swagner-de/<app>:<tag>
```

### Tags

| Tag | Description |
|-----|-------------|
| `X.Y.Z` | Immutable, pinned to specific version |
| `rolling` | Latest release, updated on each push to main |

### Verify attestation

```bash
gh attestation verify --repo swagner-de/containers oci://ghcr.io/swagner-de/<app>:rolling
```

## Adding a new app

See [CONTRIBUTING.md](CONTRIBUTING.md).
