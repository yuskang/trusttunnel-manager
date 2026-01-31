#!/bin/bash
#
# TrustTunnel Manager - 配置管理模組
# 包含配置查看、修改和匯出功能
#

# 確保 common.sh 已載入
if [[ -z "$ENDPOINT_DIR" ]]; then
    echo "錯誤: 請先載入 common.sh" >&2
    exit 1
fi

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
