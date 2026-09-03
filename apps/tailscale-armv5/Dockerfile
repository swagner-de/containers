# syntax=docker/dockerfile:1

# Tailscale for MikroTik hEX-class routers: 32-bit ARMv5 (linux/arm/v5).
# The official tailscale/tailscale image is armv7 and dies with SIGILL (illegal
# instruction) on these CPUs, so we build from source with GOARM=5.

# Cross-compile on the native build host — no armv5 emulation for the Go build.
FROM --platform=$BUILDPLATFORM golang:1.27-alpine AS build-env
ARG VERSION
RUN apk add --no-cache git upx
WORKDIR /go/src
RUN git -c advice.detachedHead=false clone --depth 1 \
      --branch "v${VERSION}" https://github.com/tailscale/tailscale.git
WORKDIR /go/src/tailscale
RUN go mod download
# GOARM=5 is the whole point — Go's default GOARM=7 is what SIGILLs on the hEX.
RUN eval "$(./build_dist.sh shellvars)" && \
    GOARCH=arm GOARM=5 CGO_ENABLED=0 go build -ldflags="-w -s \
      -X tailscale.com/version.Long=$VERSION_LONG \
      -X tailscale.com/version.Short=$VERSION_SHORT \
      -X tailscale.com/version.GitCommit=$VERSION_GIT_HASH" \
      -o /out/ ./cmd/tailscale ./cmd/tailscaled
RUN upx /out/tailscale /out/tailscaled

# Debian armel is the ARMv5 userland — alpine has no arm/v5 manifest.
FROM debian:trixie-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates iptables iproute2 procps \
 && rm -rf /var/lib/apt/lists/* \
 # MikroTik's kernel has no nf_tables — force the legacy iptables backend.
 && update-alternatives --set iptables  /usr/sbin/iptables-legacy \
 && update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
COPY --from=build-env /out/ /usr/local/bin/
COPY --chmod=755 tailscale.sh /usr/local/bin/
# Runs as root: a subnet router needs NET_ADMIN, iptables and ip_forward.
CMD ["/usr/local/bin/tailscale.sh"]
