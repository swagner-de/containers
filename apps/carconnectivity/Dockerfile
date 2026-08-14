# syntax=docker/dockerfile:1

# Builder base tracks the same Debian release as the distroless runtime below
# (both debian13 => Python 3.13). Keeping them on the same Debian line
# guarantees the interpreter minor versions match, so the venv's site-packages
# are ABI/stdlib-compatible with the runtime. Bump both in lockstep only.
FROM docker.io/library/debian:13-slim AS builder

ARG VERSION

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ENV UV_COMPILE_BYTECODE=1 \
    UV_NO_CACHE=1 \
    UV_LINK_MODE=copy

RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends python3 python3-venv && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN uv venv --python "$(command -v python3)" /opt/venv

RUN --mount=type=cache,target=/root/.cache/uv \
    VIRTUAL_ENV=/opt/venv uv pip install \
    "carconnectivity==${VERSION}" \
    "carconnectivity-connector-volkswagen>=0.10.1" \
    "carconnectivity-plugin-abrp>=0.8.1" \
    "carconnectivity-plugin-mqtt_homeassistant>=0.6.1" \
    "carconnectivity-plugin-webui>=0.7"

# Collapse the version-keyed site-packages (…/pythonX.Y/site-packages) into a
# fixed, unversioned path so the runtime never references a hardcoded Python
# minor. The glob resolves whatever minor the builder produced.
RUN mkdir -p /opt/pkgs && \
    cp -a /opt/venv/lib/python*/site-packages/. /opt/pkgs/

FROM gcr.io/distroless/python3-debian13:nonroot

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH="/opt/pkgs"

COPY --from=builder /opt/pkgs /opt/pkgs

WORKDIR /config
VOLUME ["/config"]

ENTRYPOINT ["python", "-c", "from carconnectivity.carconnectivity_base import main; main()"]
