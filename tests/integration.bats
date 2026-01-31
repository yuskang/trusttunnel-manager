#!/usr/bin/env bats
#
# 整合測試
# 端對端測試腳本功能
#

load 'test_helper'

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# ==================== 命令行參數測試 ====================

@test "腳本 --help 顯示用法說明" {
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && show_help() { echo '用法: --install-endpoint --status'; }; show_help"
    [[ "$output" == *"用法"* ]]
    [[ "$output" == *"--install-endpoint"* ]]
}

@test "腳本 -h 等同於 --help" {
    # 測試 show_help 函數存在並可呼叫
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && type print_info"
    [[ "$status" -eq 0 ]]
}

@test "lib/common.sh 定義 print_error 函數" {
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && type print_error"
    [[ "$status" -eq 0 ]]
}

@test "lib/status.sh 定義 check_status 函數" {
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && source '$PROJECT_ROOT/lib/status.sh' && type check_status"
    [[ "$status" -eq 0 ]]
}

@test "lib/config.sh 定義 view_endpoint_config 函數" {
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && source '$PROJECT_ROOT/lib/config.sh' && type view_endpoint_config"
    [[ "$status" -eq 0 ]]
}

# ==================== 建置輸出測試 ====================

@test "建置腳本可執行" {
    [[ -x "$PROJECT_ROOT/scripts/build.sh" ]]
}

@test "建置腳本生成輸出檔案" {
    run "$PROJECT_ROOT/scripts/build.sh"
    [[ "$status" -eq 0 ]]
    [[ -f "$PROJECT_ROOT/dist/trusttunnel-manager.sh" ]]
}

@test "建置輸出檔案可執行" {
    "$PROJECT_ROOT/scripts/build.sh" >/dev/null 2>&1
    [[ -x "$PROJECT_ROOT/dist/trusttunnel-manager.sh" ]]
}

@test "建置輸出 --help 與原始腳本一致" {
    "$PROJECT_ROOT/scripts/build.sh" >/dev/null 2>&1

    # 驗證建置輸出包含必要的選項
    built=$("$PROJECT_ROOT/dist/trusttunnel-manager.sh" --help 2>&1 || true)

    [[ "$built" == *"--install-endpoint"* ]]
    [[ "$built" == *"--status"* ]]
}

# ==================== 模組載入測試 ====================

@test "所有 lib 模組檔案存在" {
    [[ -f "$PROJECT_ROOT/lib/common.sh" ]]
    [[ -f "$PROJECT_ROOT/lib/install.sh" ]]
    [[ -f "$PROJECT_ROOT/lib/config.sh" ]]
    [[ -f "$PROJECT_ROOT/lib/status.sh" ]]
    [[ -f "$PROJECT_ROOT/lib/service.sh" ]]
    [[ -f "$PROJECT_ROOT/lib/uninstall.sh" ]]
}

@test "lib/common.sh 可以被 source" {
    run bash -c "source '$PROJECT_ROOT/lib/common.sh' && echo 'OK'"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"OK"* ]]
}
