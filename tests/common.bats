#!/usr/bin/env bats
#
# common.sh 單元測試
# 測試工具函數和常數定義
#

load 'test_helper'

setup() {
    setup_test_dir
    load_lib common
}

teardown() {
    teardown_test_dir
}

# ==================== 常數測試 ====================

@test "常數: ENDPOINT_DIR 已定義" {
    [[ -n "$ENDPOINT_DIR" ]]
}

@test "常數: CLIENT_DIR 已定義" {
    [[ -n "$CLIENT_DIR" ]]
}

@test "常數: SERVICE_NAME 已定義" {
    [[ -n "$SERVICE_NAME" ]]
}

# ==================== 顏色定義測試 ====================

@test "顏色: RED 已定義" {
    [[ -n "$RED" ]]
}

@test "顏色: GREEN 已定義" {
    [[ -n "$GREEN" ]]
}

@test "顏色: YELLOW 已定義" {
    [[ -n "$YELLOW" ]]
}

@test "顏色: BLUE 已定義" {
    [[ -n "$BLUE" ]]
}

@test "顏色: NC (No Color) 已定義" {
    [[ -n "$NC" ]]
}

# ==================== 輸出函數測試 ====================

@test "print_info 輸出包含 INFO 標籤" {
    run print_info "測試訊息"
    [[ "$output" == *"INFO"* ]]
}

@test "print_success 輸出包含 SUCCESS 標籤" {
    run print_success "測試訊息"
    [[ "$output" == *"SUCCESS"* ]]
}

@test "print_warning 輸出包含 WARNING 標籤" {
    run print_warning "測試訊息"
    [[ "$output" == *"WARNING"* ]]
}

@test "print_error 輸出包含 ERROR 標籤" {
    run print_error "測試訊息"
    [[ "$output" == *"ERROR"* ]]
}

@test "print_header 顯示應用標題" {
    run print_header
    [[ "$output" == *"TrustTunnel"* ]]
}

# ==================== 作業系統檢查測試 ====================

@test "check_os 在 macOS 上設定 OS=macos" {
    if [[ "$(uname)" == "Darwin" ]]; then
        check_os
        [[ "$OS" == "macos" ]]
    else
        skip "僅在 macOS 上測試"
    fi
}

@test "check_os 在 Linux 上設定 OS=linux" {
    if [[ "$(uname)" == "Linux" ]]; then
        check_os
        [[ "$OS" == "linux" ]]
    else
        skip "僅在 Linux 上測試"
    fi
}

# ==================== 安裝狀態檢查測試 ====================

@test "check_installation 未安裝時 ENDPOINT_INSTALLED=false" {
    check_installation
    [[ "$ENDPOINT_INSTALLED" == "false" ]]
}

@test "check_installation 未安裝時 CLIENT_INSTALLED=false" {
    check_installation
    [[ "$CLIENT_INSTALLED" == "false" ]]
}

@test "check_installation 已安裝 Endpoint 時 ENDPOINT_INSTALLED=true" {
    mock_endpoint_installed
    check_installation
    [[ "$ENDPOINT_INSTALLED" == "true" ]]
}

@test "check_installation 已安裝 Client 時 CLIENT_INSTALLED=true" {
    mock_client_installed
    check_installation
    [[ "$CLIENT_INSTALLED" == "true" ]]
}
