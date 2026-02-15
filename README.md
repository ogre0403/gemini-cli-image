# Agent CLI Docker Images (Codex / Gemini / Claude / OpenCode)

本專案使用單一 multi-stage Dockerfile 建置多種 Agent CLI（Codex / Gemini / Claude / OpenCode）的 Docker images，並可透過 build args 啟用額外工具。

## Image 架構

```
ogre0403/${AGENT}:${VERSION}-base (base stage: 基礎工具層，不含 CLI)
└── ogre0403/${AGENT}:${VERSION}-upstream (upstream stage: 安裝指定版本 CLI + entrypoint)
    └── ogre0403/${AGENT}:${VERSION} (release stage: 視需求加裝額外工具)
```

支援的 `AGENT`：

- `codex` → npm 套件 `@openai/codex`
- `gemini` → npm 套件 `@google/gemini-cli`
- `claude` → npm 套件 `@anthropic-ai/claude-code`
- `opencode` → npm 套件 `opencode-ai`

## Images 說明

### 1. Base Image (`ogre0403/${AGENT}:${VERSION}-base`)

**基於**: `node:24-slim`

**用途**: 提供常用開發與除錯工具，支援 Python 相關工作（不安裝任何 Agent CLI）。

**包含工具（節錄）**:
- **python3 / pipx**: 方便安裝與執行 Python 工具
- **uv**: Python 包管理工具
- **常用工具**: git, gh, jq, ripgrep, curl, dnsutils, lsof, socat 等


### 2. Upstream Image (`ogre0403/${AGENT}:${VERSION}-upstream`)

**基於**: `ogre0403/${AGENT}:${VERSION}-base`

**用途**: 安裝指定版本的 Agent CLI，並提供統一的 entrypoint。

**建置過程**:
- 依 `AGENT` 選擇對應的 npm 套件
- 使用 Node.js 24 安裝指定 `VERSION`

**Entrypoint 行為**:
- 預設執行對應的 agent command（例如 `codex`, `gemini`, `claude`, `opencode`）
- 若執行時帶入 `shell`：會改啟動互動式 shell，或執行你提供的 shell 命令（例如 `docker run ... shell "echo hi"`）
- 若 runtime 未設定 `AGENT`，entrypoint 會嘗試偵測容器內已安裝的 agent binary 後再執行

### 3. Release Image (`ogre0403/${AGENT}:${VERSION}`)

**基於**: `ogre0403/${AGENT}:${VERSION}-upstream`

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
# 建置 upstream image（安裝 CLI + entrypoint）
make upstream

# 建置 base image
make base

# 建置 release image (會自動建置 base image)
make release

# 指定 AGENT 或版本建置
make AGENT=gemini VERSION=0.1.10 release

# 其他 AGENT 範例
make AGENT=claude VERSION=latest release
make AGENT=opencode VERSION=latest release

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
