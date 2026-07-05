target "docker-metadata-action" {}

variable "APP" {
  default = "samba"
}

variable "VERSION" {
  // renovate: datasource=repology depName=alpine_3_23/samba versioning=loose
  default = "4.22.10-r0"
}

variable "SOURCE" {
  default = "https://github.com/swagner-de/containers"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    SAMBA_VERSION = "${VERSION}"
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
