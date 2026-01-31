#!/bin/bash
#
# TrustTunnel Manager - 通用模組
# 包含常數定義、顏色和工具函數
#

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 路徑定義
ENDPOINT_DIR="${ENDPOINT_DIR:-/opt/trusttunnel}"
CLIENT_DIR="${CLIENT_DIR:-/opt/trusttunnel_client}"
ENDPOINT_CONFIG="$ENDPOINT_DIR/vpn.toml"
HOSTS_CONFIG="$ENDPOINT_DIR/hosts.toml"
CLIENT_CONFIG="$CLIENT_DIR/trusttunnel_client.toml"
SERVICE_NAME="trusttunnel"

# 輸出函數
print_header() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║          TrustTunnel 一鍵管理腳本 v1.0                    ║"
    echo "║      https://github.com/TrustTunnel/TrustTunnel           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 檢查 root 權限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "此腳本需要 root 權限執行"
        print_info "請使用: sudo $0"
        exit 1
    fi
}

# 檢查系統類型
check_os() {
    if [[ "$(uname)" == "Darwin" ]]; then
        OS="macos"
    elif [[ "$(uname)" == "Linux" ]]; then
        OS="linux"
    else
        print_error "不支援的作業系統: $(uname)"
        exit 1
    fi
}

# 檢查安裝狀態
check_installation() {
    ENDPOINT_INSTALLED=false
    CLIENT_INSTALLED=false

    if [[ -d "$ENDPOINT_DIR" ]] && [[ -f "$ENDPOINT_DIR/trusttunnel_endpoint" ]]; then
        ENDPOINT_INSTALLED=true
    fi

    if [[ -d "$CLIENT_DIR" ]] && [[ -f "$CLIENT_DIR/trusttunnel_client" ]]; then
        CLIENT_INSTALLED=true
    fi
}
