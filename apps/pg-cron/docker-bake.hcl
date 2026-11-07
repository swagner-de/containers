target "docker-metadata-action" {}

variable "APP" {
  default = "pg-cron"
}

# Empty: resolved dynamically by resolve-version.sh (e.g. 1.6.8-18-trixie).
variable "VERSION" {
  default = ""
}

variable "SOURCE" {
  default = "https://github.com/swagner-de/containers"
}

variable "DESCRIPTION" {
  default = <<-EOT
    A [pg_cron](https://github.com/citusdata/pg_cron) extension image for
    [CloudNativePG](https://cloudnative-pg.io/), packaged as a mountable
    [image volume extension](https://cloudnative-pg.github.io/docs/devel/imagevolume_extensions).
    Built `FROM scratch` with the `/lib` + `/share` layout CNPG expects; it is
    mounted read-only into the PostgreSQL pod, not run as a container.

    The tag encodes `<pg_cron>-<pg_major>-<distro>` (e.g. `1.6.8-18-trixie`): a
    pg_cron shared library is ABI-bound to the PostgreSQL major and OS, so pick
    the tag matching your cluster's operand image. Requires PostgreSQL 18+.

    Enable it in a `Cluster`, then install it in the target database:

    ```yaml
    apiVersion: postgresql.cnpg.io/v1
    kind: Cluster
    metadata:
      name: cluster-pg-cron
    spec:
      imageName: ghcr.io/cloudnative-pg/postgresql:18-minimal-trixie
      instances: 1
      storage:
        size: 1Gi
      postgresql:
        # pg_cron must be preloaded and scoped to one database.
        shared_preload_libraries:
          - pg_cron
        parameters:
          cron.database_name: app
          # Run jobs via background workers. Without this, pg_cron connects over
          # TCP as `postgres`, which CNPG's pg_hba rejects (scram, no password),
          # and jobs fail with "connection failed".
          cron.use_background_workers: "on"
        extensions:
          - name: pg_cron
            image:
              reference: ghcr.io/swagner-de/containers/pg-cron:1.6.8-18-trixie
    ---
    apiVersion: postgresql.cnpg.io/v1
    kind: Database
    metadata:
      name: cluster-pg-cron-app
    spec:
      name: app
      owner: app
      cluster:
        name: cluster-pg-cron
      extensions:
        - name: pg_cron
    ```
  EOT
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output   = ["type=docker"]
  tags     = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
