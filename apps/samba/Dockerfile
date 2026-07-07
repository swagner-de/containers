# syntax=docker/dockerfile:1

FROM docker.io/library/alpine:3.24

RUN apk add --no-cache \
        samba-server \
        samba-common-tools \
        samba-client \
    && rm -rf /tmp/*

COPY entrypoint.sh /entrypoint.sh

EXPOSE 445/tcp
ENTRYPOINT ["/entrypoint.sh"]
