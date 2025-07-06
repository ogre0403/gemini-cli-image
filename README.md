# Gemini Docker Images

本專案基於 `us-docker.pkg.dev/gemini-code-dev/gemini-cli/sandbox` 原始 image，建立了兩個自訂的 Docker images，以提供不同層級的功能擴展。

## Image 架構

```
us-docker.pkg.dev/gemini-code-dev/gemini-cli/sandbox:${VERSION}
└── ogre0403/gemini:${VERSION}-base (Dockerfile.base)
    └── ogre0403/gemini:${VERSION} (Dockerfile.release)
```

## Images 說明

### 1. Base Image (`ogre0403/gemini:${VERSION}-base`)

**基於**: `us-docker.pkg.dev/gemini-code-dev/gemini-cli/sandbox:${VERSION}`

**用途**: 提供基礎開發工具的增強版本

**新增功能**:
- **vim**: 文字編輯器，提供更好的檔案編輯體驗
- **uv**: Python 包管理工具，用於快速的 Python 套件安裝和管理

**與原始 image 的差異**:
- 增加了文字編輯能力
- 提供了現代化的 Python 包管理工具
- 保持原有的 gemini CLI 功能

### 2. Release Image (`ogre0403/gemini:${VERSION}`)

**基於**: `ogre0403/gemini:${VERSION}-base`

**用途**: 提供完整的雲端開發環境，特別適合 OpenStack 相關開發

**新增功能**:
- **python3-dev**: Python 開發標頭檔，支援編譯 Python 擴展
- **python3-openstackclient**: OpenStack 命令列工具，用於管理 OpenStack 雲端資源

**與 Base Image 的差異**:
- 增加了 OpenStack 雲端管理能力
- 支援更複雜的 Python 開發需求
- 提供完整的雲端開發工具鏈

**與原始 image 的差異**:
- 包含 Base Image 的所有功能
- 增加了雲端資源管理能力
- 支援 OpenStack 環境的操作和管理

## 建置方式

### 使用 Makefile

```bash
# 建置 base image
make base

# 建置 release image (會自動建置 base image)
make release

# 指定版本建置
make VERSION=0.1.10 release

```

