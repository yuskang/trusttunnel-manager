#!/bin/bash
#
# TrustTunnel Manager - 安裝模組
# 包含 Endpoint 和 Client 的安裝功能
#

# 確保 common.sh 已載入
if [[ -z "$ENDPOINT_DIR" ]]; then
    echo "錯誤: 請先載入 common.sh" >&2
    exit 1
fi

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
