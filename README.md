# Gemini Docker Images

本專案基於 Google Gemini CLI 官方專案，建立了三個層級的自訂 Docker images，以提供不同功能擴展需求。

## Image 架構

```
gemini-cli 官方原始碼 (github.com/google-gemini/gemini-cli)
└── ogre0403/gemini:${VERSION}-upstream (本地建置的 upstream image)
    └── ogre0403/gemini:${VERSION}-base (Dockerfile.base)
        └── ogre0403/gemini:${VERSION} (Dockerfile.release)
```

## Images 說明

### 1. Upstream Image (`ogre0403/gemini:${VERSION}-upstream`)

**基於**: Google Gemini CLI 官方原始碼

**用途**: 從官方原始碼建置的基礎 Gemini CLI image

**建置過程**:
- 從 GitHub 克隆 gemini-cli 官方儲存庫
- 使用 Node.js 20 編譯和打包 CLI 和 Core 套件
- 建置為 Docker image

### 2. Base Image (`ogre0403/gemini:${VERSION}-base`)

**基於**: `ogre0403/gemini:${VERSION}-upstream`

**用途**: 提供uv和 vim 等基礎開發工具的增強版本，可以直接使用python開發的MCP Server

**新增功能**:
- **vim**: 文字編輯器，提供更好的檔案編輯體驗
- **uv**: Python 包管理工具，用於快速的 Python 套件安裝和管理


### 3. Release Image (`ogre0403/gemini:${VERSION}`)

**基於**: `ogre0403/gemini:${VERSION}-base`

**用途**: 安裝OpenStack CLI 工具，讓 [OpenStack MCP Server](https://github.com/ogre0403/simple-openstack-mcp) 可以直接使用

**新增功能**:
- **python3-dev**: Python 開發標頭檔，支援編譯 Python 擴展
- **python3-openstackclient**: OpenStack 命令列工具，用於管理 OpenStack 雲端資源

## 建置方式

### 使用 Makefile

**預設版本**: 0.1.9

```bash
# 建置 upstream image (從官方原始碼)
make upstream

# 建置 base image
make base

# 建置 release image (會自動建置 base image)
make release

# 指定版本建置
make VERSION=0.1.10 release

# 完整建置流程 (upstream -> base -> release)
make upstream && make release
```

### 可用的 Make targets

- `upstream`: 從 GitHub 官方儲存庫建置 upstream image
- `base`: 建置包含基礎開發工具的 base image
- `release`: 建置包含完整功能的 release image



