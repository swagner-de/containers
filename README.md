# Containers

Container images built and published to GHCR.

## Images

All images are rootless (UID 65534), multi-arch, scanned daily, and signed with GitHub attestations.

| App | Version | Source | Platforms |
|-----|---------|--------|-----------|
| [`carconnectivity`](apps/carconnectivity) | `0.11.9` | [Source](https://github.com/tillsteinbach/CarConnectivity) | linux/amd64, linux/arm64 |

## Usage

```bash
docker pull ghcr.io/swagner-de/containers/<app>:<tag>
```

## Adding a new app

See [CONTRIBUTING.md](CONTRIBUTING.md).
