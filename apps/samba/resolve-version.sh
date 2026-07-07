#!/bin/sh
# Resolve the samba-server version currently available in the Alpine repo
# that matches this app's base image tag.
set -eu

alpine_tag=$(sed -n 's|^FROM docker\.io/library/alpine:\(.*\)|\1|p' Dockerfile | head -1)

docker run --rm "docker.io/library/alpine:${alpine_tag}" sh -c '
    apk update >/dev/null 2>&1
    apk info samba-server | head -1 | sed "s/^samba-server-//; s/ .*//"
'
