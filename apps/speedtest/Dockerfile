# syntax=docker/dockerfile:1

FROM node:24-alpine AS builder
ARG VERSION
WORKDIR /build
RUN corepack enable && \
    apk add --no-cache git && \
    git clone --depth 1 --branch v${VERSION} https://github.com/cloudflare/speedtest.git .
COPY serve.mjs .
RUN pnpm install --frozen-lockfile --ignore-scripts && \
    pnpm build

FROM gcr.io/distroless/nodejs22-debian12:nonroot

WORKDIR /app
COPY --from=builder /build/serve.mjs       ./serve.mjs
COPY --from=builder /build/dist/speedtest.js ./public/speedtest.js
COPY index.html                             ./public/index.html
# Default config — override by mounting /config/config.json at runtime
COPY config.json                            ./config.json

USER nobody:nobody
EXPOSE 8080
CMD ["serve.mjs"]
