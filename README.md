# Codex/Gemini Docker Images

本專案使用單一 multi-stage Dockerfile 建置 Codex 或 Gemini CLI 的多層 Docker images，並可透過 build args 啟用額外工具。

## Image 架構

```
官方 CLI npm 套件 (@openai/codex 或 @google/gemini-cli)
└── ogre0403/${AGENT}:${VERSION}-upstream (upstream stage)
    └── ogre0403/${AGENT}:${VERSION}-base (base stage)
        └── ogre0403/${AGENT}:${VERSION} (release stage)
```

## Images 說明

### 1. Upstream Image (`ogre0403/${AGENT}:${VERSION}-upstream`)

**基於**: 官方 npm 套件

**用途**: 安裝指定版本的 CLI，並提供 entrypoint。

**建置過程**:
- 依 `AGENT` 選擇套件 (`openai/codex` 或 `google/gemini-cli`)
- 使用 Node.js 24 安裝指定版本

### 2. Base Image (`ogre0403/${AGENT}:${VERSION}-base`)

**基於**: `ogre0403/${AGENT}:${VERSION}-upstream`

**用途**: 提供常用開發與除錯工具，支援 Python 相關工作。

**新增功能**:
- **python3 / pipx**: 方便安裝與執行 Python 工具
- **uv**: Python 包管理工具
- **常用工具**: git, gh, jq, ripgrep, curl, dnsutils, lsof, socat 等


### 3. Release Image (`ogre0403/${AGENT}:${VERSION}`)

**基於**: `ogre0403/${AGENT}:${VERSION}-base`

**用途**: 依需求啟用額外工具（預設不安裝）。

**可選功能**:
- **tcpdump / tshark**: 網路分析工具（`ENABLE_TCPDUMP=true`）
- **python-openstackclient**: OpenStack CLI（`ENABLE_OPENSTACK=true`）
- **ENABLE_ALL=true**: 啟用所有額外功能

## 建置方式

### 使用 Makefile

**預設參數**:
- `AGENT=codex`
- `VERSION=latest`

```bash
# 建置 upstream image (從官方原始碼)
make upstream

# 建置 base image
make base

# 建置 release image (會自動建置 base image)
make release

# 指定 AGENT 或版本建置
make AGENT=gemini VERSION=0.1.10 release

# 完整建置流程 (upstream -> base -> release)
make upstream && make release

# 啟用額外工具
make release ENABLE_TCPDUMP=true
make release ENABLE_OPENSTACK=true
make release ENABLE_ALL=true
```

### Multi-arch push

```bash
make push-release
```

### 可用的 build 參數

- `ENABLE_TCPDUMP=true`: 啟用 tcpdump/tshark
- `ENABLE_OPENSTACK=true`: 啟用 OpenStack client
- `ENABLE_ALL=true`: 啟用全部額外功能
```

### 可用的 Make targets

- `upstream`: 建置 upstream image
- `base`: 建置包含基礎開發工具的 base image
- `release`: 建置包含完整功能的 release image
- `release-all`: 以 `ENABLE_ALL=true` 建置 release
- `push-release`: multi-arch buildx push
- `clean`: 清理本地 images



## codex configuration

```
model = "gpt-5.2-codex"  # Replace with your actual Azure model deployment name
model_provider = "azure"
model_reasoning_effort = "low"

[model_providers.azure]
name = "Azure OpenAI"
base_url = "https://<YOUR_AZURE_PROJECT_RESOURCE>.cognitiveservices.azure.com/openai/v1"
env_key = "AZURE_OPENAI_API_KEY"
wire_api = "responses"
```
