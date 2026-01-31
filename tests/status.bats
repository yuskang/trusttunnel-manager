#!/usr/bin/env bats
#
# status.sh 單元測試
# 測試狀態檢查功能
#

load 'test_helper'

setup() {
    setup_test_dir
    load_lib common
    load_lib status
    check_os
}

teardown() {
    teardown_test_dir
}

# ==================== check_status 測試 ====================

@test "check_status 未安裝時顯示未安裝狀態" {
    check_installation
    run check_status
    [[ "$output" == *"未安裝"* ]]
}

@test "check_status 已安裝 Endpoint 時顯示已安裝" {
    mock_endpoint_installed
    check_installation
    run check_status
    [[ "$output" == *"已安裝"* ]]
}

@test "check_status 顯示配置文件狀態" {
    mock_endpoint_installed
    check_installation
    run check_status
    [[ "$output" == *"配置文件"* ]]
}

@test "check_status 顯示進程狀態" {
    check_installation
    run check_status
    [[ "$output" == *"進程狀態"* ]]
}

@test "check_status 顯示網路狀態" {
    check_installation
    run check_status
    [[ "$output" == *"網路狀態"* ]]
}
