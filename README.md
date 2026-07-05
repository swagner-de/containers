# Containers

Container images built and published to GHCR.

## Images

All images are rootless (UID 65534), multi-arch, scanned daily, and signed with GitHub attestations.

| App | Version | Source | Platforms |
|-----|---------|--------|-----------|
| [`carconnectivity`](apps/carconnectivity) | `0.11.10` | [Source](https://github.com/tillsteinbach/CarConnectivity) | linux/amd64, linux/arm64 |
| [`samba`](apps/samba) | `4.22.10-r0` | [Source](https://github.com/swagner-de/containers) | linux/amd64, linux/arm64 |
| [`speedtest`](apps/speedtest) | `1.11.0` | [Source](https://github.com/cloudflare/speedtest) | linux/amd64, linux/arm64 |

## Usage

```bash
docker pull ghcr.io/swagner-de/containers/<app>:<tag>
```

## Adding a new app

See [CONTRIBUTING.md](CONTRIBUTING.md).
