# syntax=docker/dockerfile:1

FROM docker.io/library/alpine:3.24
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN \
    apk add --no-cache \
        bash \
        ca-certificates \
        catatonit \
        curl \
        jq \
        tzdata \
    && rm -rf /tmp/*

# TODO: Install your application here
# Example:
# RUN curl -fsSL "https://github.com/CHANGEME/releases/download/v${VERSION}/app-linux-${TARGETARCH}" \
#         -o /app/bin/app \
#     && chmod +x /app/bin/app

COPY . /

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
