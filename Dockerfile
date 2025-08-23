# Multi-stage Dockerfile for gemini-cli
ARG VERSION=0.1.9
ARG ENABLE_TCPDUMP=false
ARG ENABLE_OPENSTACK=false
ARG ENABLE_ALL=false

# Stage 1: Build upstream (equivalent to upstream image)
FROM node:20-alpine AS upstream
ARG VERSION

RUN npm install -g @google/gemini-cli@${VERSION} && \
    npm cache clean --force

CMD ["gemini"]

# Stage 2: Base image (equivalent to base image)
FROM upstream AS base

RUN apk add --no-cache \
    vim   \
    bash  \
    jq    \
    git   \
    curl

RUN apk add --no-cache \
    python3-dev \
    pipx        \
    gcc         \
    musl-dev    \
    linux-headers

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh


# Stage 3: Release image (equivalent to release image)
FROM base AS release
ARG ENABLE_TCPDUMP
ARG ENABLE_OPENSTACK
ARG ENABLE_ALL

# Install tcpdump analysis tool (if enabled)
RUN if [ "$ENABLE_ALL" = "true" ] || [ "$ENABLE_TCPDUMP" = "true" ]; then \
        apk add --no-cache tshark tcpdump; \
    fi

# Install openstack client tool (if enabled)
RUN if [ "$ENABLE_ALL" = "true" ] || [ "$ENABLE_OPENSTACK" = "true" ]; then \
        pipx install python-openstackclient && \
        pipx ensurepath; \
    fi

