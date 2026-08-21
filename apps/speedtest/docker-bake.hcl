target "docker-metadata-action" {}

variable "APP" {
  default = "speedtest"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=cloudflare/speedtest
  default = "1.13.1"
}

variable "SOURCE" {
  default = "https://github.com/cloudflare/speedtest"
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

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
