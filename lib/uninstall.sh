#!/bin/bash
#
# TrustTunnel Manager - 解除安裝模組
# 包含 Endpoint 和 Client 的移除功能
#

# 確保 common.sh 已載入
if [[ -z "$ENDPOINT_DIR" ]]; then
    echo "錯誤: 請先載入 common.sh" >&2
    exit 1
fi

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
