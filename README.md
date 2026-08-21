# Containers

Container images built and published to GHCR.

## Images

All images are rootless (UID 65534), multi-arch, scanned daily, and signed with GitHub attestations.

| App | Version | Revision | Source | Platforms |
|-----|---------|----------|--------|-----------|
| [`carconnectivity`](apps/carconnectivity) | `0.11.10` | `0.11.10-b1` | [Source](https://github.com/tillsteinbach/CarConnectivity) | linux/amd64, linux/arm64 |
| [`iperf3`](apps/iperf3) | `3.21` | `3.21-b1` | [Source](https://github.com/esnet/iperf) | linux/amd64, linux/arm64 |
| [`samba`](apps/samba) | `4.23.8-r0` | `4.23.8-r0-b1` | [Source](https://github.com/swagner-de/containers) | linux/amd64, linux/arm64 |
| [`speedtest`](apps/speedtest) | `1.13.1` | `1.13.1-b0` | [Source](https://github.com/cloudflare/speedtest) | linux/amd64, linux/arm64 |
| [`tailscale-armv5`](apps/tailscale-armv5) | `1.102.3` | `1.102.3-b0` | [Source](https://github.com/tailscale/tailscale) | linux/arm/v5 |

## Usage

```bash
docker pull ghcr.io/swagner-de/containers/<app>:<tag>
```

## Adding a new app

See [CONTRIBUTING.md](CONTRIBUTING.md).
