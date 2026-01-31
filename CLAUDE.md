# Project: TrustTunnel Manager

## 專案資訊

**類型：** CLI Tool (Bash)

**技術棧：**
- Shell: Bash 4.0+
- Init System: systemd
- Config Format: TOML
- Testing: BATS (Bash Automated Testing System)
- Linting: ShellCheck

**目標平台：**
- Linux (主要支援)
- macOS (部分支援)

## 專案結構

```
trusttunnel-manager/
├── trusttunnel-manager.sh    # 主入口腳本 (開發時 source lib/)
├── lib/                      # 模組化函式庫
│   ├── common.sh             # 常數、顏色、工具函數
│   ├── install.sh            # 安裝功能
│   ├── config.sh             # 配置管理
│   ├── status.sh             # 狀態檢查
│   ├── service.sh            # 服務控制
│   └── uninstall.sh          # 解除安裝
├── tests/                    # BATS 測試
│   ├── test_helper.bash      # 測試工具和 mock
│   ├── common.bats           # 工具函數測試
│   ├── status.bats           # 狀態檢查測試
│   ├── config.bats           # 配置管理測試
│   ├── install.bats          # 安裝功能測試
│   ├── uninstall.bats        # 解除安裝測試
│   ├── service.bats          # 服務控制測試
│   └── integration.bats      # 端對端測試
├── scripts/                  # 建置腳本
│   └── build.sh              # 打包成單一檔案
├── dist/                     # 打包輸出目錄
├── .github/workflows/        # CI/CD
│   └── ci.yml                # GitHub Actions
├── Makefile                  # 自動化指令
├── .shellcheckrc             # ShellCheck 配置
└── README.md                 # 專案說明
```

## 開發規範

### 命名慣例
- 函數：snake_case (e.g., `check_status`, `install_endpoint`)
- 常數：UPPER_SNAKE_CASE (e.g., `ENDPOINT_DIR`, `SERVICE_NAME`)
- 檔案：kebab-case (e.g., `trusttunnel-manager.sh`)
- 模組：snake_case.sh (e.g., `common.sh`)

### Git 分支
- main: 生產環境
- develop: 開發環境
- feature/*: 功能開發
- hotfix/*: 緊急修復

### Commit 格式
```
type(scope): description

[optional body]
```

Types: feat, fix, docs, style, refactor, test, chore

## 常用指令

```bash
# 靜態分析
make lint

# 運行測試
make test

# 打包成單一檔案
make build

# 清理建置產物
make clean

# 運行所有檢查
make all
```

## 開發模式 vs 發布模式

### 開發模式
- 主腳本使用 `source lib/*.sh` 載入模組
- 方便調試和修改個別模組
- 運行 `./trusttunnel-manager.sh` 直接執行

### 發布模式
- 運行 `make build` 生成 `dist/trusttunnel-manager.sh`
- 單一檔案包含所有模組
- 適合分發和部署

## 測試覆蓋目標

- 單元測試覆蓋率: 80%+
- 每個模組有對應的 .bats 測試檔案
- 整合測試驗證端對端流程

## 注意事項

- 此專案已有初版，正在進行模組化重構
- 打包後的單一檔案應與開發模式行為一致
- 所有變更需通過 ShellCheck 和 BATS 測試
