#!/bin/bash
#
# TrustTunnel 一鍵管理腳本
# 支援：安裝、配置調閱、修改配置、移除、狀態檢查
# 基於：https://github.com/TrustTunnel/TrustTunnel
#
# 此檔案由 scripts/build.sh 自動生成
# 請勿直接編輯，修改應在 lib/*.sh 中進行
#

set -e


# ==================== common.sh ====================
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

# ==================== install.sh ====================
#
# TrustTunnel Manager - 安裝模組
# 包含 Endpoint 和 Client 的安裝功能
#


install_endpoint() {
    print_info "正在安裝 TrustTunnel Endpoint..."

    if [[ "$ENDPOINT_INSTALLED" == true ]]; then
        print_warning "Endpoint 已安裝，將進行更新"
    fi

    if curl -fsSL https://raw.githubusercontent.com/TrustTunnel/TrustTunnel/refs/heads/master/scripts/install.sh | sh -s -; then
        print_success "Endpoint 安裝完成"
        print_info "安裝目錄: $ENDPOINT_DIR"

        # 重新檢查安裝狀態
        check_installation

        read -p "是否立即執行配置精靈？(y/n): " run_wizard
        if [[ "$run_wizard" =~ ^[Yy]$ ]]; then
            configure_endpoint
        fi
    else
        print_error "Endpoint 安裝失敗"
        return 1
    fi
}

install_client() {
    print_info "正在安裝 TrustTunnel Client..."

    if [[ "$CLIENT_INSTALLED" == true ]]; then
        print_warning "Client 已安裝，將進行更新"
    fi

    if curl -fsSL https://raw.githubusercontent.com/TrustTunnel/TrustTunnelClient/refs/heads/master/scripts/install.sh | sh -s -; then
        print_success "Client 安裝完成"
        print_info "安裝目錄: $CLIENT_DIR"

        # 重新檢查安裝狀態
        check_installation

        read -p "是否立即執行配置精靈？(y/n): " run_wizard
        if [[ "$run_wizard" =~ ^[Yy]$ ]]; then
            configure_client
        fi
    else
        print_error "Client 安裝失敗"
        return 1
    fi
}

install_menu() {
    echo ""
    echo -e "${CYAN}=== 安裝選項 ===${NC}"
    echo "1) 安裝 Endpoint (伺服器端)"
    echo "2) 安裝 Client (客戶端)"
    echo "3) 安裝指定版本的 Endpoint"
    echo "0) 返回主選單"
    echo ""
    read -p "請選擇: " choice

    case $choice in
        1) install_endpoint ;;
        2) install_client ;;
        3)
            read -p "請輸入版本號: " version
            print_info "正在安裝 Endpoint 版本: $version"
            curl -fsSL https://raw.githubusercontent.com/TrustTunnel/TrustTunnel/refs/heads/master/scripts/install.sh | sh -s - -V "$version"
            ;;
        0) return ;;
        *) print_error "無效選擇" ;;
    esac
}

# ==================== config.sh ====================
#
# TrustTunnel Manager - 配置管理模組
# 包含配置查看、修改和匯出功能
#


# ==================== 配置調閱 ====================

view_endpoint_config() {
    if [[ "$ENDPOINT_INSTALLED" != true ]]; then
        print_error "Endpoint 尚未安裝"
        return 1
    fi

    echo ""
    echo -e "${CYAN}=== Endpoint 配置文件 ===${NC}"

    if [[ -f "$ENDPOINT_CONFIG" ]]; then
        echo -e "${YELLOW}--- vpn.toml ---${NC}"
        cat "$ENDPOINT_CONFIG"
        echo ""
    else
        print_warning "vpn.toml 不存在"
    fi

    if [[ -f "$HOSTS_CONFIG" ]]; then
        echo -e "${YELLOW}--- hosts.toml ---${NC}"
        cat "$HOSTS_CONFIG"
        echo ""
    else
        print_warning "hosts.toml 不存在"
    fi
}

view_client_config() {
    if [[ "$CLIENT_INSTALLED" != true ]]; then
        print_error "Client 尚未安裝"
        return 1
    fi

    echo ""
    echo -e "${CYAN}=== Client 配置文件 ===${NC}"

    if [[ -f "$CLIENT_CONFIG" ]]; then
        echo -e "${YELLOW}--- trusttunnel_client.toml ---${NC}"
        cat "$CLIENT_CONFIG"
        echo ""
    else
        print_warning "trusttunnel_client.toml 不存在"
    fi
}

view_config_menu() {
    echo ""
    echo -e "${CYAN}=== 調閱配置 ===${NC}"
    echo "1) 查看 Endpoint 配置"
    echo "2) 查看 Client 配置"
    echo "3) 查看所有配置"
    echo "0) 返回主選單"
    echo ""
    read -p "請選擇: " choice

    case $choice in
        1) view_endpoint_config ;;
        2) view_client_config ;;
        3)
            view_endpoint_config
            view_client_config
            ;;
        0) return ;;
        *) print_error "無效選擇" ;;
    esac
}

# ==================== 修改配置 ====================

configure_endpoint() {
    if [[ "$ENDPOINT_INSTALLED" != true ]]; then
        print_error "Endpoint 尚未安裝"
        return 1
    fi

    print_info "啟動 Endpoint 配置精靈..."
    cd "$ENDPOINT_DIR" || return 1
    ./setup_wizard
}

configure_client() {
    if [[ "$CLIENT_INSTALLED" != true ]]; then
        print_error "Client 尚未安裝"
        return 1
    fi

    print_info "啟動 Client 配置精靈..."
    cd "$CLIENT_DIR" || return 1
    ./setup_wizard
}

edit_config_file() {
    local config_file="$1"
    local editor="${EDITOR:-nano}"

    if [[ ! -f "$config_file" ]]; then
        print_error "配置文件不存在: $config_file"
        return 1
    fi

    # 備份配置
    cp "$config_file" "${config_file}.bak.$(date +%Y%m%d%H%M%S)"
    print_info "已建立備份: ${config_file}.bak.$(date +%Y%m%d%H%M%S)"

    $editor "$config_file"
    print_success "配置已修改"
}

export_client_config() {
    if [[ "$ENDPOINT_INSTALLED" != true ]]; then
        print_error "Endpoint 尚未安裝"
        return 1
    fi

    read -p "請輸入客戶端名稱: " client_name
    read -p "請輸入公網 IP: " public_ip

    cd "$ENDPOINT_DIR" || return 1
    ./trusttunnel_endpoint vpn.toml hosts.toml -c "$client_name" -a "$public_ip"

    print_success "客戶端配置已匯出"
}

modify_config_menu() {
    echo ""
    echo -e "${CYAN}=== 修改配置 ===${NC}"
    echo "1) 執行 Endpoint 配置精靈"
    echo "2) 執行 Client 配置精靈"
    echo "3) 手動編輯 vpn.toml"
    echo "4) 手動編輯 hosts.toml"
    echo "5) 手動編輯 trusttunnel_client.toml"
    echo "6) 從 Endpoint 匯出 Client 配置"
    echo "0) 返回主選單"
    echo ""
    read -p "請選擇: " choice

    case $choice in
        1) configure_endpoint ;;
        2) configure_client ;;
        3) edit_config_file "$ENDPOINT_CONFIG" ;;
        4) edit_config_file "$HOSTS_CONFIG" ;;
        5) edit_config_file "$CLIENT_CONFIG" ;;
        6) export_client_config ;;
        0) return ;;
        *) print_error "無效選擇" ;;
    esac
}

# ==================== status.sh ====================
#
# TrustTunnel Manager - 狀態檢查模組
# 包含安裝、服務和網路狀態檢查
#


check_status() {
    echo ""
    echo -e "${CYAN}=== TrustTunnel 狀態檢查 ===${NC}"
    echo ""

    # 安裝狀態
    echo -e "${YELLOW}[安裝狀態]${NC}"
    if [[ "$ENDPOINT_INSTALLED" == true ]]; then
        echo -e "  Endpoint: ${GREEN}已安裝${NC} ($ENDPOINT_DIR)"
        if [[ -f "$ENDPOINT_DIR/trusttunnel_endpoint" ]]; then
            version=$("$ENDPOINT_DIR/trusttunnel_endpoint" --version 2>/dev/null || echo "未知")
            echo -e "  版本: $version"
        fi
    else
        echo -e "  Endpoint: ${RED}未安裝${NC}"
    fi

    if [[ "$CLIENT_INSTALLED" == true ]]; then
        echo -e "  Client: ${GREEN}已安裝${NC} ($CLIENT_DIR)"
        if [[ -f "$CLIENT_DIR/trusttunnel_client" ]]; then
            version=$("$CLIENT_DIR/trusttunnel_client" --version 2>/dev/null || echo "未知")
            echo -e "  版本: $version"
        fi
    else
        echo -e "  Client: ${RED}未安裝${NC}"
    fi
    echo ""

    # 服務狀態 (Linux)
    if [[ "$OS" == "linux" ]]; then
        echo -e "${YELLOW}[服務狀態]${NC}"
        if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
            echo -e "  systemd 服務: ${GREEN}運行中${NC}"
        elif systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
            echo -e "  systemd 服務: ${YELLOW}已啟用但未運行${NC}"
        else
            echo -e "  systemd 服務: ${RED}未配置${NC}"
        fi
        echo ""
    fi

    # 配置文件狀態
    echo -e "${YELLOW}[配置文件]${NC}"
    if [[ -f "$ENDPOINT_CONFIG" ]]; then
        echo -e "  vpn.toml: ${GREEN}存在${NC}"
    else
        echo -e "  vpn.toml: ${RED}不存在${NC}"
    fi

    if [[ -f "$HOSTS_CONFIG" ]]; then
        echo -e "  hosts.toml: ${GREEN}存在${NC}"
    else
        echo -e "  hosts.toml: ${RED}不存在${NC}"
    fi

    if [[ -f "$CLIENT_CONFIG" ]]; then
        echo -e "  trusttunnel_client.toml: ${GREEN}存在${NC}"
    else
        echo -e "  trusttunnel_client.toml: ${RED}不存在${NC}"
    fi
    echo ""

    # 網路狀態
    echo -e "${YELLOW}[網路狀態]${NC}"

    # 檢查監聽端口
    if command -v ss &> /dev/null; then
        listening=$(ss -tlnp 2>/dev/null | grep -E "trusttunnel" || echo "")
        if [[ -n "$listening" ]]; then
            echo "  監聽端口:"
            echo "$listening" | while read line; do
                echo "    $line"
            done
        else
            echo "  監聯端口: 無"
        fi
    elif command -v netstat &> /dev/null; then
        listening=$(netstat -tlnp 2>/dev/null | grep -E "trusttunnel" || echo "")
        if [[ -n "$listening" ]]; then
            echo "  監聽端口:"
            echo "$listening" | while read line; do
                echo "    $line"
            done
        else
            echo "  監聽端口: 無"
        fi
    fi

    # 檢查 TUN 介面
    if ip link show 2>/dev/null | grep -q "tun"; then
        echo -e "  TUN 介面: ${GREEN}存在${NC}"
        ip link show 2>/dev/null | grep "tun" | while read line; do
            echo "    $line"
        done
    else
        echo -e "  TUN 介面: ${YELLOW}無${NC}"
    fi
    echo ""

    # 進程狀態
    echo -e "${YELLOW}[進程狀態]${NC}"
    endpoint_pid=$(pgrep -f "trusttunnel_endpoint" 2>/dev/null || echo "")
    client_pid=$(pgrep -f "trusttunnel_client" 2>/dev/null || echo "")

    if [[ -n "$endpoint_pid" ]]; then
        echo -e "  Endpoint 進程: ${GREEN}運行中${NC} (PID: $endpoint_pid)"
    else
        echo -e "  Endpoint 進程: ${RED}未運行${NC}"
    fi

    if [[ -n "$client_pid" ]]; then
        echo -e "  Client 進程: ${GREEN}運行中${NC} (PID: $client_pid)"
    else
        echo -e "  Client 進程: ${RED}未運行${NC}"
    fi
    echo ""
}

# ==================== service.sh ====================
#
# TrustTunnel Manager - 服務控制模組
# 包含 systemd 服務管理功能
#


setup_systemd_service() {
    if [[ ! -f "/etc/systemd/system/$SERVICE_NAME.service" ]]; then
        if [[ -f "$ENDPOINT_DIR/trusttunnel.service.template" ]]; then
            print_info "正在安裝 systemd 服務..."
            cp "$ENDPOINT_DIR/trusttunnel.service.template" "/etc/systemd/system/$SERVICE_NAME.service"
            systemctl daemon-reload
            print_success "systemd 服務已安裝"
            return 0
        else
            print_error "找不到服務模板文件: $ENDPOINT_DIR/trusttunnel.service.template"
            print_info "請確保 Endpoint 已正確安裝"
            return 1
        fi
    fi
    return 0
}

service_control_menu() {
    if [[ "$OS" != "linux" ]]; then
        print_warning "服務控制僅支援 Linux 系統"
        return 1
    fi

    if [[ "$ENDPOINT_INSTALLED" != true ]]; then
        print_error "Endpoint 尚未安裝，無法控制服務"
        return 1
    fi

    echo ""
    echo -e "${CYAN}=== 服務控制 ===${NC}"
    echo "1) 啟動服務"
    echo "2) 停止服務"
    echo "3) 重啟服務"
    echo "4) 啟用開機自動啟動"
    echo "5) 禁用開機自動啟動"
    echo "6) 查看服務日誌"
    echo "7) 安裝/重新安裝 systemd 服務"
    echo "0) 返回主選單"
    echo ""
    read -p "請選擇: " choice

    case $choice in
        1)
            setup_systemd_service || return 1
            systemctl start "$SERVICE_NAME"
            print_success "服務已啟動"
            ;;
        2)
            systemctl stop "$SERVICE_NAME"
            print_success "服務已停止"
            ;;
        3)
            setup_systemd_service || return 1
            systemctl restart "$SERVICE_NAME"
            print_success "服務已重啟"
            ;;
        4)
            if [[ ! -f "/etc/systemd/system/$SERVICE_NAME.service" ]]; then
                if [[ -f "$ENDPOINT_DIR/trusttunnel.service.template" ]]; then
                    cp "$ENDPOINT_DIR/trusttunnel.service.template" "/etc/systemd/system/$SERVICE_NAME.service"
                    systemctl daemon-reload
                else
                    print_error "找不到服務模板文件"
                    return 1
                fi
            fi
            systemctl enable "$SERVICE_NAME"
            print_success "已啟用開機自動啟動"
            ;;
        5)
            systemctl disable "$SERVICE_NAME"
            print_success "已禁用開機自動啟動"
            ;;
        6)
            journalctl -u "$SERVICE_NAME" -n 50 --no-pager
            ;;
        0) return ;;
        *) print_error "無效選擇" ;;
    esac
}

# ==================== uninstall.sh ====================
#
# TrustTunnel Manager - 解除安裝模組
# 包含 Endpoint 和 Client 的移除功能
#


uninstall_endpoint() {
    if [[ "$ENDPOINT_INSTALLED" != true ]]; then
        print_warning "Endpoint 未安裝"
        return 0
    fi

    read -p "確定要移除 Endpoint？這將刪除所有配置！(y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "取消移除"
        return 0
    fi

    # 停止服務
    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        print_info "停止 TrustTunnel 服務..."
        systemctl stop "$SERVICE_NAME"
    fi

    # 禁用服務
    if systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
        print_info "禁用 TrustTunnel 服務..."
        systemctl disable "$SERVICE_NAME"
    fi

    # 移除服務文件
    if [[ -f "/etc/systemd/system/$SERVICE_NAME.service" ]]; then
        rm -f "/etc/systemd/system/$SERVICE_NAME.service"
        systemctl daemon-reload
    fi

    # 備份配置（可選）
    read -p "是否備份配置文件？(y/n): " backup
    if [[ "$backup" =~ ^[Yy]$ ]]; then
        backup_dir="/root/trusttunnel_backup_$(date +%Y%m%d%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r "$ENDPOINT_DIR"/*.toml "$backup_dir/" 2>/dev/null || true
        print_info "配置已備份到: $backup_dir"
    fi

    # 移除安裝目錄
    rm -rf "$ENDPOINT_DIR"

    print_success "Endpoint 已完全移除"
}

uninstall_client() {
    if [[ "$CLIENT_INSTALLED" != true ]]; then
        print_warning "Client 未安裝"
        return 0
    fi

    read -p "確定要移除 Client？這將刪除所有配置！(y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "取消移除"
        return 0
    fi

    # 備份配置（可選）
    read -p "是否備份配置文件？(y/n): " backup
    if [[ "$backup" =~ ^[Yy]$ ]]; then
        backup_dir="/root/trusttunnel_client_backup_$(date +%Y%m%d%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r "$CLIENT_DIR"/*.toml "$backup_dir/" 2>/dev/null || true
        print_info "配置已備份到: $backup_dir"
    fi

    # 移除安裝目錄
    rm -rf "$CLIENT_DIR"

    print_success "Client 已完全移除"
}

uninstall_menu() {
    echo ""
    echo -e "${CYAN}=== 移除安裝 ===${NC}"
    echo "1) 移除 Endpoint"
    echo "2) 移除 Client"
    echo "3) 完全移除（Endpoint + Client）"
    echo "0) 返回主選單"
    echo ""
    read -p "請選擇: " choice

    case $choice in
        1) uninstall_endpoint ;;
        2) uninstall_client ;;
        3)
            uninstall_endpoint
            uninstall_client
            ;;
        0) return ;;
        *) print_error "無效選擇" ;;
    esac
}

# ==================== 主選單 ====================

main_menu() {
    while true; do
        print_header
        check_installation

        echo -e "${YELLOW}當前狀態:${NC}"
        if [[ "$ENDPOINT_INSTALLED" == true ]]; then
            echo -e "  Endpoint: ${GREEN}已安裝${NC}"
        else
            echo -e "  Endpoint: ${RED}未安裝${NC}"
        fi
        if [[ "$CLIENT_INSTALLED" == true ]]; then
            echo -e "  Client: ${GREEN}已安裝${NC}"
        else
            echo -e "  Client: ${RED}未安裝${NC}"
        fi
        echo ""

        echo -e "${CYAN}=== 主選單 ===${NC}"
        echo "1) 安裝"
        echo "2) 調閱配置"
        echo "3) 修改配置"
        echo "4) 移除安裝"
        echo "5) 檢查狀態"
        echo "6) 服務控制 (Linux)"
        echo "0) 退出"
        echo ""
        read -p "請選擇: " choice

        case $choice in
            1) install_menu ;;
            2) view_config_menu ;;
            3) modify_config_menu ;;
            4) uninstall_menu ;;
            5) check_status ;;
            6) service_control_menu ;;
            0)
                print_info "再見！"
                exit 0
                ;;
            *)
                print_error "無效選擇"
                ;;
        esac

        echo ""
        read -p "按 Enter 繼續..."
    done
}

# ==================== 命令行參數支援 ====================

show_help() {
    echo "用法: $0 [選項]"
    echo ""
    echo "選項:"
    echo "  --install-endpoint    安裝 Endpoint"
    echo "  --install-client      安裝 Client"
    echo "  --uninstall-endpoint  移除 Endpoint"
    echo "  --uninstall-client    移除 Client"
    echo "  --status              檢查狀態"
    echo "  --view-config         查看所有配置"
    echo "  --start               啟動服務"
    echo "  --stop                停止服務"
    echo "  --restart             重啟服務"
    echo "  -h, --help            顯示此幫助"
    echo ""
    echo "不帶參數執行將進入互動式選單"
}

# 主程序入口
check_os

if [[ $# -eq 0 ]]; then
    check_root
    main_menu
else
    case "$1" in
        --install-endpoint)
            check_root
            check_installation
            install_endpoint
            ;;
        --install-client)
            check_root
            check_installation
            install_client
            ;;
        --uninstall-endpoint)
            check_root
            check_installation
            uninstall_endpoint
            ;;
        --uninstall-client)
            check_root
            check_installation
            uninstall_client
            ;;
        --status)
            check_installation
            check_status
            ;;
        --view-config)
            check_installation
            view_endpoint_config
            view_client_config
            ;;
        --start)
            check_root
            systemctl start "$SERVICE_NAME"
            print_success "服務已啟動"
            ;;
        --stop)
            check_root
            systemctl stop "$SERVICE_NAME"
            print_success "服務已停止"
            ;;
        --restart)
            check_root
            systemctl restart "$SERVICE_NAME"
            print_success "服務已重啟"
            ;;
        -h|--help)
            show_help
            ;;
        *)
            print_error "未知選項: $1"
            show_help
            exit 1
            ;;
    esac
fi
