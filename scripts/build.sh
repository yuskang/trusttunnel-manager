#!/bin/bash
#
# TrustTunnel Manager 建置腳本
# 將模組化的 lib/*.sh 打包成單一可執行檔案
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/dist"
OUTPUT_FILE="$OUTPUT_DIR/trusttunnel-manager.sh"

# 確保輸出目錄存在
mkdir -p "$OUTPUT_DIR"

echo "開始建置 TrustTunnel Manager..."

# 建立輸出檔案
cat > "$OUTPUT_FILE" << 'HEADER'
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

HEADER

# 依序合併模組（按依賴順序）
MODULES=(
    "common.sh"
    "install.sh"
    "config.sh"
    "status.sh"
    "service.sh"
    "uninstall.sh"
)

for module in "${MODULES[@]}"; do
    module_path="$PROJECT_ROOT/lib/$module"
    if [[ -f "$module_path" ]]; then
        echo "  合併模組: $module"
        echo "" >> "$OUTPUT_FILE"
        echo "# ==================== $module ====================" >> "$OUTPUT_FILE"
        # 跳過 shebang 和模組檢查行
        tail -n +2 "$module_path" | grep -v "^# 確保 common.sh 已載入" | grep -v "^if \[\[ -z \"\$ENDPOINT_DIR\"" | grep -v "^    echo \"錯誤: 請先載入 common.sh\"" | grep -v "^    exit 1$" | grep -v "^fi$" >> "$OUTPUT_FILE" || true
    else
        echo "  警告: 模組不存在 - $module"
    fi
done

# 添加主選單和命令行處理（從原始腳本提取）
cat >> "$OUTPUT_FILE" << 'MAIN_MENU'

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
MAIN_MENU

# 設定執行權限
chmod +x "$OUTPUT_FILE"

echo ""
echo "建置完成！"
echo "輸出檔案: $OUTPUT_FILE"
echo ""
echo "驗證方式:"
echo "  shellcheck $OUTPUT_FILE"
echo "  $OUTPUT_FILE --help"
