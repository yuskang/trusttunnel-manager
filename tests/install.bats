#!/usr/bin/env bats
#
# install.sh 單元測試
# 測試安裝功能
#

load 'test_helper'

setup() {
    setup_test_dir
    load_lib common
    load_lib config
    load_lib install
}

teardown() {
    teardown_test_dir
}

# ==================== install_endpoint 測試 ====================

# 注意：實際安裝測試需要網路和 root 權限
# 這裡只測試前置條件檢查

@test "install_endpoint 已安裝時顯示更新警告" {
    mock_endpoint_installed
    check_installation

    # Mock curl 以避免實際下載
    curl() { echo "mock curl"; return 0; }
    export -f curl

    # 由於需要互動，這裡只測試警告輸出
    # 實際測試應使用 expect 或 mock read
    skip "需要互動式輸入"
}

# ==================== install_menu 測試 ====================

@test "install_menu 顯示選項" {
    # Mock read 返回 0（返回主選單）
    MOCK_READ_VALUE="0"

    # 無法直接測試互動式選單
    skip "需要互動式輸入"
}
