#!/usr/bin/env bats
#
# config.sh 單元測試
# 測試配置管理功能
#

load 'test_helper'

setup() {
    setup_test_dir
    load_lib common
    load_lib config
}

teardown() {
    teardown_test_dir
}

# ==================== view_endpoint_config 測試 ====================

@test "view_endpoint_config 未安裝時返回錯誤" {
    check_installation
    run view_endpoint_config
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"尚未安裝"* ]]
}

@test "view_endpoint_config 已安裝時顯示配置" {
    mock_endpoint_installed
    check_installation
    run view_endpoint_config
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"vpn.toml"* ]]
}

@test "view_endpoint_config 顯示 hosts.toml 內容" {
    mock_endpoint_installed
    check_installation
    run view_endpoint_config
    [[ "$output" == *"hosts.toml"* ]]
}

# ==================== view_client_config 測試 ====================

@test "view_client_config 未安裝時返回錯誤" {
    check_installation
    run view_client_config
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"尚未安裝"* ]]
}

@test "view_client_config 已安裝時顯示配置" {
    mock_client_installed
    check_installation
    run view_client_config
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"trusttunnel_client.toml"* ]]
}

# ==================== edit_config_file 測試 ====================

@test "edit_config_file 文件不存在時返回錯誤" {
    run edit_config_file "/nonexistent/file.toml"
    [[ "$status" -eq 1 ]]
    [[ "$output" == *"不存在"* ]]
}

@test "edit_config_file 建立備份檔案" {
    mock_endpoint_installed
    # 使用 cat 作為編輯器來避免互動
    EDITOR="cat" run edit_config_file "$ENDPOINT_CONFIG"
    # 檢查備份檔案存在
    backup_count=$(ls "$ENDPOINT_DIR"/*.bak.* 2>/dev/null | wc -l)
    [[ "$backup_count" -ge 1 ]]
}
