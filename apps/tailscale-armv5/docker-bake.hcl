target "docker-metadata-action" {}

variable "APP" {
  default = "tailscale-armv5"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=tailscale/tailscale
  default = "1.102.2"
}

variable "SOURCE" {
  default = "https://github.com/tailscale/tailscale"
}

variable "DESCRIPTION" {
  default = "Purpose-built Tailscale image for 32-bit **ARMv5** MikroTik routers (hEX-class). The official `tailscale/tailscale` image is ARMv7 and dies with SIGILL (illegal instruction) on these CPUs, so this builds from source with `GOARM=5` on a Debian armel base. Single-arch `linux/arm/v5` — not a general-purpose multi-arch image."
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
  }
}

# arm/v5-only app: pin the local build too, otherwise it packages the
# GOARM=5 binaries inside a native (amd64) userland and won't run.
target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  platforms = ["linux/arm/v5"]
  tags = ["${APP}:${VERSION}"]
}

# ARMv5 only — this image targets 32-bit ARMv5 MikroTik routers (hEX-class).
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/arm/v5"
  ]
}
