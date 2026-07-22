# syntax=docker/dockerfile:1

FROM docker.io/library/python:3.14-slim AS builder
ARG VERSION

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ENV UV_COMPILE_BYTECODE=1 \
    UV_NO_CACHE=1 \
    UV_LINK_MODE=copy

WORKDIR /build

RUN uv venv --python /usr/local/bin/python3.13 /opt/venv

RUN --mount=type=cache,target=/root/.cache/uv \
    VIRTUAL_ENV=/opt/venv uv pip install \
    "carconnectivity==${VERSION}" \
    "carconnectivity-connector-volkswagen>=0.10.1" \
    "carconnectivity-plugin-abrp>=0.8.1" \
    "carconnectivity-plugin-mqtt_homeassistant>=0.6.1" \
    "carconnectivity-plugin-webui>=0.7"

FROM gcr.io/distroless/python3-debian13:nonroot

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY --from=builder /opt/venv/lib/python3.13/site-packages /opt/venv/lib/python3.13/site-packages
ENV PYTHONPATH="/opt/venv/lib/python3.13/site-packages"

WORKDIR /config
VOLUME ["/config"]

ENTRYPOINT ["python", "-c", "from carconnectivity.carconnectivity_base import main; main()"]
