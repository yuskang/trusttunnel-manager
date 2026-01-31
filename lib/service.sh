#!/bin/bash
#
# TrustTunnel Manager - 服務控制模組
# 包含 systemd 服務管理功能
#

# 確保 common.sh 已載入
if [[ -z "$ENDPOINT_DIR" ]]; then
    echo "錯誤: 請先載入 common.sh" >&2
    exit 1
fi

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
