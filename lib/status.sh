#!/bin/bash
#
# TrustTunnel Manager - 狀態檢查模組
# 包含安裝、服務和網路狀態檢查
#

# 確保 common.sh 已載入
if [[ -z "$ENDPOINT_DIR" ]]; then
    echo "錯誤: 請先載入 common.sh" >&2
    exit 1
fi

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
