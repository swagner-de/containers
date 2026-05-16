# syntax=docker/dockerfile:1

FROM docker.io/library/golang:1.26-alpine AS builder
ARG VERSION
WORKDIR /build

# TODO: Build your static binary here
# Example:
# RUN CGO_ENABLED=0 go install github.com/CHANGEME/cmd/app@v${VERSION}

FROM gcr.io/distroless/static:nonroot

# TODO: Copy your binary from the builder stage
# COPY --from=builder /go/bin/app /app

USER nobody:nobody
ENTRYPOINT ["/app"]
