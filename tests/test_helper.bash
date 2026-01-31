#!/bin/bash
#
# BATS 測試輔助函數
# 提供 mock 函數和測試工具
#

# 測試環境設定
export TEST_MODE=true
export BATS_TEST_DIRNAME="${BATS_TEST_DIRNAME:-$(dirname "${BASH_SOURCE[0]}")}"
export PROJECT_ROOT="${BATS_TEST_DIRNAME}/.."

# 載入被測試的函數
load_lib() {
    local lib_name="$1"
    # shellcheck source=/dev/null
    source "${PROJECT_ROOT}/lib/${lib_name}.sh"
}

# 載入所有函式庫
load_all_libs() {
    for lib in common install config status service uninstall; do
        if [[ -f "${PROJECT_ROOT}/lib/${lib}.sh" ]]; then
            # shellcheck source=/dev/null
            source "${PROJECT_ROOT}/lib/${lib}.sh"
        fi
    done
}

# ==================== Mock 函數 ====================

# Mock systemctl
mock_systemctl() {
    local action="$1"
    local service="$2"

    case "$action" in
        is-active)
            [[ "${MOCK_SERVICE_ACTIVE:-false}" == "true" ]] && return 0 || return 1
            ;;
        is-enabled)
            [[ "${MOCK_SERVICE_ENABLED:-false}" == "true" ]] && return 0 || return 1
            ;;
        start|stop|restart|enable|disable|daemon-reload)
            echo "mock: systemctl $action $service"
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Mock curl
mock_curl() {
    echo "mock: curl $*"
    return 0
}

# Mock read (用於互動式測試)
mock_read() {
    local var_name="$1"
    eval "$var_name=\"${MOCK_READ_VALUE:-y}\""
}

# ==================== 測試輔助函數 ====================

# 建立暫存測試目錄
setup_test_dir() {
    export TEST_TEMP_DIR
    TEST_TEMP_DIR=$(mktemp -d)
    export ENDPOINT_DIR="$TEST_TEMP_DIR/opt/trusttunnel"
    export CLIENT_DIR="$TEST_TEMP_DIR/opt/trusttunnel_client"
    export ENDPOINT_CONFIG="$ENDPOINT_DIR/vpn.toml"
    export HOSTS_CONFIG="$ENDPOINT_DIR/hosts.toml"
    export CLIENT_CONFIG="$CLIENT_DIR/trusttunnel_client.toml"
}

# 清理暫存測試目錄
teardown_test_dir() {
    if [[ -n "${TEST_TEMP_DIR:-}" ]] && [[ -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# 模擬 Endpoint 安裝
mock_endpoint_installed() {
    mkdir -p "$ENDPOINT_DIR"
    touch "$ENDPOINT_DIR/trusttunnel_endpoint"
    chmod +x "$ENDPOINT_DIR/trusttunnel_endpoint"

    # 建立配置檔案
    cat > "$ENDPOINT_CONFIG" << 'EOF'
[server]
listen_addr = "0.0.0.0:51820"
private_key = "test_private_key"
EOF

    cat > "$HOSTS_CONFIG" << 'EOF'
[[hosts]]
name = "client1"
public_key = "test_public_key"
allowed_ips = ["10.0.0.2/32"]
EOF
}

# 模擬 Client 安裝
mock_client_installed() {
    mkdir -p "$CLIENT_DIR"
    touch "$CLIENT_DIR/trusttunnel_client"
    chmod +x "$CLIENT_DIR/trusttunnel_client"

    # 建立配置檔案
    cat > "$CLIENT_CONFIG" << 'EOF'
[client]
server_addr = "example.com:51820"
private_key = "client_private_key"
EOF
}

# 檢查輸出包含特定文字
assert_output_contains() {
    local expected="$1"
    if [[ "$output" != *"$expected"* ]]; then
        echo "Expected output to contain: $expected"
        echo "Actual output: $output"
        return 1
    fi
}

# 檢查輸出不包含特定文字
assert_output_not_contains() {
    local unexpected="$1"
    if [[ "$output" == *"$unexpected"* ]]; then
        echo "Expected output NOT to contain: $unexpected"
        echo "Actual output: $output"
        return 1
    fi
}

# 檢查檔案存在
assert_file_exists() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "Expected file to exist: $file"
        return 1
    fi
}

# 檢查目錄存在
assert_dir_exists() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        echo "Expected directory to exist: $dir"
        return 1
    fi
}
