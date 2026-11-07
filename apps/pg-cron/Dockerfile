# syntax=docker/dockerfile:1

# Not a runnable image: a CloudNativePG ImageVolume extension, mounted read-only
# at /extensions/<name> with the /lib + /share layout PostgreSQL discovers.
# https://cloudnative-pg.github.io/docs/devel/imagevolume_extensions

# PG_MAJOR/DISTRO pick the base image and are read back by resolve-version.sh.
ARG PG_MAJOR=18
ARG DISTRO=trixie
ARG BASE=ghcr.io/cloudnative-pg/postgresql:${PG_MAJOR}-minimal-${DISTRO}

FROM ${BASE} AS builder

ARG PG_MAJOR

USER 0

# Unpinned by design (dynamic-version app): resolve-version.sh tags the image
# with whatever pgdg ships, so base-image bumps don't need a coupled pin.
RUN apt-get update \
    && apt-get install -y --no-install-recommends "postgresql-${PG_MAJOR}-cron" \
    && rm -rf /var/lib/apt/lists/*

FROM scratch
ARG PG_MAJOR

COPY --from=builder /usr/share/doc/postgresql-${PG_MAJOR}-cron/copyright /licenses/postgresql-${PG_MAJOR}-cron/
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/pg_cron* /lib/
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/bitcode/ /lib/bitcode/
COPY --from=builder /usr/share/postgresql/${PG_MAJOR}/extension/pg_cron* /share/extension/

USER 65532:65532
