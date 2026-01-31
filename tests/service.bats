#!/usr/bin/env bats
#
# service.sh 單元測試
# 測試服務控制功能
#

load 'test_helper'

setup() {
    setup_test_dir
    load_lib common
    load_lib service
    check_os

    # Mock systemctl
    systemctl() { mock_systemctl "$@"; }
    export -f systemctl
}

teardown() {
    teardown_test_dir
}

# ==================== setup_systemd_service 測試 ====================

@test "setup_systemd_service 找不到模板時返回錯誤" {
    mock_endpoint_installed
    # 不建立模板檔案
    run setup_systemd_service
    [[ "$status" -eq 1 ]] || [[ "$output" == *"找不到"* ]]
}

# ==================== service_control_menu 測試 ====================

@test "service_control_menu 在 macOS 上顯示警告" {
    if [[ "$(uname)" == "Darwin" ]]; then
        run service_control_menu
        [[ "$output" == *"僅支援 Linux"* ]]
    else
        skip "僅在 macOS 上測試"
    fi
}

@test "service_control_menu 未安裝 Endpoint 時返回錯誤" {
    if [[ "$(uname)" == "Linux" ]]; then
        check_installation
        run service_control_menu
        [[ "$output" == *"尚未安裝"* ]]
    else
        skip "僅在 Linux 上測試"
    fi
}
