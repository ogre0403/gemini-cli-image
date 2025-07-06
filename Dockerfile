# Multi-stage Dockerfile for gemini-cli
ARG VERSION=0.1.9

# Stage 1: Build upstream (equivalent to upstream image)
FROM node:20-slim AS upstream-builder
ARG VERSION
WORKDIR /gemini-cli

# Clone and build gemini-cli
RUN apt update && apt install -y git
RUN git clone https://github.com/google-gemini/gemini-cli.git .
RUN git checkout v${VERSION}
RUN npm install

# Package CLI
WORKDIR /gemini-cli/packages/cli
RUN npm pack && mkdir -p dist && mv *.tgz dist/

# Package Core
WORKDIR /gemini-cli/packages/core
RUN npm pack && mkdir -p dist && mv *.tgz dist/

# Stage 2: Create upstream runtime image

FROM node:20-slim AS upstream
ARG VERSION
ARG SANDBOX_NAME="gemini-cli-sandbox"
ARG CLI_VERSION_ARG
ENV SANDBOX="$SANDBOX_NAME"
ENV CLI_VERSION=$CLI_VERSION_ARG

# install minimal set of packages, then clean up
RUN apt-get update && apt-get install -y --no-install-recommends \
  python3 \
  make \
  g++ \
  man-db \
  curl \
  dnsutils \
  less \
  jq \
  bc \
  gh \
  git \
  unzip \
  rsync \
  ripgrep \
  procps \
  psmisc \
  lsof \
  socat \
  ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set up npm global package folder under /usr/local/share
# give it to non-root user node, already set up in base image
RUN mkdir -p /usr/local/share/npm-global \
  && chown -R node:node /usr/local/share/npm-global
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# switch to non-root user node
USER node

# Copy packages from upstream-builder stage, then install gemini-cli and clean up
COPY --from=upstream-builder /gemini-cli/packages/core/dist/google-gemini-cli-core-*.tgz /usr/local/share/npm-global/gemini-core.tgz
COPY --from=upstream-builder /gemini-cli/packages/cli/dist/google-gemini-cli-*.tgz /usr/local/share/npm-global/gemini-cli.tgz
RUN npm install -g /usr/local/share/npm-global/gemini-cli.tgz /usr/local/share/npm-global/gemini-core.tgz \
  && npm cache clean --force \
  && rm -f /usr/local/share/npm-global/gemini-{cli,core}.tgz

# default entrypoint when none specified
CMD ["gemini"]


# Stage 3: Base image (equivalent to base image)
FROM upstream AS base
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh

USER node
CMD ["gemini"]

# Stage 4: Release image (equivalent to release image)
FROM base AS release
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-dev \
    python3-openstackclient \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER node
CMD ["gemini"]
