# Multi-stage Dockerfile for gemini-cli
ARG VERSION=0.1.9
ARG AGENT=gemini
ARG ENABLE_TCPDUMP=false
ARG ENABLE_OPENSTACK=false
ARG ENABLE_GOLANG=false
ARG GOLANG_VERSION=
ARG ENABLE_ALL=false

# Stage 1: Build upstream (equivalent to upstream image)
FROM node:24-slim AS base

RUN apt-get update && apt-get install -y --no-install-recommends \
  python3 \
  pipx	\
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

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh

# Stage 2: Base image (equivalent to base image)
FROM base AS upstream
ARG VERSION
ARG AGENT

RUN sh -c ' \
    case "$AGENT" in \
        codex)    PACKAGE_NAME="@openai/codex"              ; CMD="codex"    ;; \
        gemini)   PACKAGE_NAME="@google/gemini-cli"         ; CMD="gemini"   ;; \
        claude)   PACKAGE_NAME="@anthropic-ai/claude-code"  ; CMD="claude"   ;; \
        opencode) PACKAGE_NAME="opencode-ai"                ; CMD="opencode" ;; \
        *) echo "Unknown AGENT: $AGENT" && exit 1 ;; \
    esac && \
    npm install -g ${PACKAGE_NAME}@${VERSION} && \
    npm cache clean --force \
    '

ENV AGENT=${AGENT}
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD []



# Stage 3: Release image (equivalent to release image)
FROM upstream AS release
ARG ENABLE_TCPDUMP
ARG ENABLE_OPENSTACK
ARG ENABLE_GOLANG
ARG GOLANG_VERSION
ARG ENABLE_ALL

# Install tcpdump analysis tool (if enabled)
RUN if [ "$ENABLE_ALL" = "true" ] || [ "$ENABLE_TCPDUMP" = "true" ]; then \
        apt install -y --no-install-recommends  tshark tcpdump; \
    fi

# Install openstack client tool (if enabled)
RUN if [ "$ENABLE_ALL" = "true" ] || [ "$ENABLE_OPENSTACK" = "true" ]; then \
        pipx install python-openstackclient && \
        pipx ensurepath; \
    fi

# Install golang binary (latest stable release, if enabled)
RUN if [ "$ENABLE_ALL" = "true" ] || [ "$ENABLE_GOLANG" = "true" ]; then \
        LATEST_GO=$(curl -fsSL 'https://go.dev/dl/?mode=json' | jq -r '.[0].version') && \
        ARCH=$(dpkg --print-architecture) && \
        curl -fsSL "https://go.dev/dl/${LATEST_GO}.linux-${ARCH}.tar.gz" -o /tmp/go.tar.gz && \
        tar -C /usr/local -xzf /tmp/go.tar.gz && \
        rm /tmp/go.tar.gz && \
        ln -sf /usr/local/go/bin/go /usr/local/bin/go && \
        ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt; \
    fi

# Set GOTOOLCHAIN if a specific Go version is requested
ENV GOTOOLCHAIN=${GOLANG_VERSION:+go${GOLANG_VERSION}}

# Force get the specific version of Go download in specific GOPATH
ENV GOPATH=/tmp/go
RUN go version
