#!/bin/sh
# Print the image version "<ext>-<pg_major>-<distro>" (e.g. 1.6.8-18-trixie).
# All three components discriminate ABI-incompatible pg_cron builds, so each
# gets its own tag.
set -eu

arg_default() {
    sed -n "s|^ARG $1=\\(.*\\)|\\1|p" Dockerfile | head -1
}

pg_major=$(arg_default PG_MAJOR)
distro=$(arg_default DISTRO)
base="ghcr.io/cloudnative-pg/postgresql:${pg_major}-minimal-${distro}"

# Candidate version, Debian suffix stripped: 1.6.8-1.pgdg13+2 -> 1.6.8
ext=$(docker run --rm --user 0 "${base}" sh -c "
    apt-get update >/dev/null 2>&1
    apt-cache policy postgresql-${pg_major}-cron \
        | sed -n 's/^  Candidate: //p' \
        | sed 's/-.*//'
")

printf '%s-%s-%s' "${ext}" "${pg_major}" "${distro}"
