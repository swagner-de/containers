# syntax=docker/dockerfile:1

# Built against glibc (Debian) rather than static musl: static musl iperf3
# hits EFAULT reading /dev/urandom when run as a non-root user (musl 1.2.6),
# which crashes the server on the first client cookie. glibc avoids this.
FROM docker.io/library/debian:trixie-slim AS builder
ARG VERSION
WORKDIR /build
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential ca-certificates && \
    rm -rf /var/lib/apt/lists/*
ADD https://downloads.es.net/pub/iperf/iperf-${VERSION}.tar.gz /build/
RUN tar xzf iperf-${VERSION}.tar.gz && \
    cd iperf-${VERSION} && \
    ./configure --disable-shared --without-openssl && \
    make -j"$(nproc)" && \
    strip src/iperf3 && \
    cp src/iperf3 /iperf3

# cc (not base/static): iperf3 dynamically links glibc and needs libgcc_s.so.1
# for pthread_cancel, plus glibc's NSS modules for hostname (DNS) resolution.
FROM gcr.io/distroless/cc-debian13:nonroot

COPY --from=builder /iperf3 /iperf3
USER nobody:nobody
EXPOSE 5201/tcp 5201/udp
ENTRYPOINT ["/iperf3"]
CMD ["-s"]
