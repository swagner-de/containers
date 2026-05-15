target "docker-metadata-action" {}

variable "APP" {
  default = "carconnectivity"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=carconnectivity
  default = "0.11.9"
}

variable "SOURCE" {
  default = "https://github.com/tillsteinbach/CarConnectivity"
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
