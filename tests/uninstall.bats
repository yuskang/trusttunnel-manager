#!/usr/bin/env bats
#
# uninstall.sh 單元測試
# 測試解除安裝功能
#

load 'test_helper'

setup() {
    setup_test_dir
    load_lib common
    load_lib uninstall

    # Mock systemctl
    systemctl() { mock_systemctl "$@"; }
    export -f systemctl
}

teardown() {
    teardown_test_dir
}

# ==================== uninstall_endpoint 測試 ====================

@test "uninstall_endpoint 未安裝時顯示警告" {
    check_installation
    run uninstall_endpoint
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"未安裝"* ]]
}

@test "uninstall_endpoint 需要確認" {
    mock_endpoint_installed
    check_installation

    # 輸入 n 取消
    run bash -c 'echo "n" | source tests/test_helper.bash && load_lib common && load_lib uninstall && check_installation && uninstall_endpoint'
    # 應該取消移除
    skip "需要互動式輸入"
}

# ==================== uninstall_client 測試 ====================

@test "uninstall_client 未安裝時顯示警告" {
    check_installation
    run uninstall_client
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"未安裝"* ]]
}
