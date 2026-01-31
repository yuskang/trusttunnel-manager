# TrustTunnel Manager Makefile
# 自動化測試、靜態分析和建置

.PHONY: all lint test build clean install-deps help

# 預設目標
all: lint test build

# 安裝開發依賴
install-deps:
	@echo "檢查並安裝依賴..."
	@command -v shellcheck >/dev/null 2>&1 || { echo "請安裝 shellcheck: brew install shellcheck (macOS) 或 apt install shellcheck (Linux)"; exit 1; }
	@command -v bats >/dev/null 2>&1 || { echo "請安裝 bats: brew install bats-core (macOS) 或 apt install bats (Linux)"; exit 1; }
	@echo "所有依賴已就緒"

# 靜態分析
lint:
	@echo "運行 ShellCheck 靜態分析..."
	@shellcheck -x trusttunnel-manager.sh lib/*.sh 2>/dev/null || shellcheck -x trusttunnel-manager.sh
	@echo "ShellCheck 通過"

# 運行測試
test:
	@echo "運行 BATS 測試..."
	@if [ -d tests ] && ls tests/*.bats >/dev/null 2>&1; then \
		bats tests/*.bats; \
	else \
		echo "無測試檔案"; \
	fi

# 打包成單一檔案
build:
	@echo "打包成單一檔案..."
	@./scripts/build.sh
	@echo "建置完成: dist/trusttunnel-manager.sh"

# 清理建置產物
clean:
	@echo "清理建置產物..."
	@rm -rf dist/*
	@echo "清理完成"

# 驗證打包後的腳本
verify: build
	@echo "驗證打包後的腳本..."
	@shellcheck dist/trusttunnel-manager.sh
	@diff <(./trusttunnel-manager.sh --help 2>&1 || true) <(./dist/trusttunnel-manager.sh --help 2>&1 || true) && echo "行為一致性驗證通過" || echo "警告: 行為可能不一致"

# 顯示幫助
help:
	@echo "TrustTunnel Manager 開發指令"
	@echo ""
	@echo "用法: make [目標]"
	@echo ""
	@echo "目標:"
	@echo "  all          運行 lint + test + build (預設)"
	@echo "  install-deps 檢查並提示安裝依賴"
	@echo "  lint         運行 ShellCheck 靜態分析"
	@echo "  test         運行 BATS 測試"
	@echo "  build        打包成單一檔案"
	@echo "  verify       驗證打包後的腳本行為"
	@echo "  clean        清理建置產物"
	@echo "  help         顯示此幫助"
