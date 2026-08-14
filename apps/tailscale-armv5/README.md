# tailscale-armv5

Purpose-built Tailscale image for 32-bit **ARMv5** MikroTik routers (hEX-class). The official `tailscale/tailscale` image is ARMv7 and dies with SIGILL (illegal instruction) on these CPUs, so this builds from source with `GOARM=5` on a Debian armel base. Single-arch `linux/arm/v5` — not a general-purpose multi-arch image.

| | |
|---|---|
| **Version** | `1.102.2` |
| **Revision** | `1.102.2-b0` |
| **Source** | [https://github.com/tailscale/tailscale](https://github.com/tailscale/tailscale) |
| **Platforms** | linux/arm/v5 |
| **Image** | `ghcr.io/swagner-de/containers/tailscale-armv5` |

## Usage

```bash
docker pull ghcr.io/swagner-de/containers/tailscale-armv5:1.102.2-b0
```

## Verify attestation

```bash
gh attestation verify --repo swagner-de/containers oci://ghcr.io/swagner-de/containers/tailscale-armv5:rolling
```
