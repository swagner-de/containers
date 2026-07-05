# syntax=docker/dockerfile:1

FROM docker.io/library/alpine:3.23

# renovate: datasource=repology depName=alpine_3_23/samba versioning=loose
ARG SAMBA_VERSION=4.22.10-r0

RUN apk add --no-cache \
        samba-server=${SAMBA_VERSION} \
        samba-common-tools=${SAMBA_VERSION} \
        samba-client=${SAMBA_VERSION} \
    && rm -rf /tmp/*

COPY entrypoint.sh /entrypoint.sh

EXPOSE 445/tcp
ENTRYPOINT ["/entrypoint.sh"]
