# TrustTunnel Manager

一鍵管理腳本，用於安裝、配置和管理 [TrustTunnel](https://github.com/TrustTunnel/TrustTunnel) VPN 協定。

## 功能

| 功能 | 說明 |
|------|------|
| **安裝** | Endpoint (伺服器端) / Client (客戶端) / 指定版本 |
| **調閱配置** | 查看 vpn.toml、hosts.toml、trusttunnel_client.toml |
| **修改配置** | 配置精靈 / 手動編輯（自動備份）/ 匯出 Client 配置 |
| **移除安裝** | 完整移除，可選備份配置 |
| **狀態檢查** | 安裝狀態、服務狀態、配置文件、網路、進程 |
| **服務控制** | 啟動/停止/重啟/開機自啟 (Linux systemd) |

## 快速安裝

```bash
curl -fsSL https://raw.githubusercontent.com/yuskang/trusttunnel-manager/main/trusttunnel-manager.sh -o trusttunnel-manager.sh
chmod +x trusttunnel-manager.sh
sudo ./trusttunnel-manager.sh
```

## 使用方式

### 互動式選單

```bash
sudo ./trusttunnel-manager.sh
```

### 命令行參數

```bash
# 安裝
sudo ./trusttunnel-manager.sh --install-endpoint
sudo ./trusttunnel-manager.sh --install-client

# 狀態與配置
sudo ./trusttunnel-manager.sh --status
sudo ./trusttunnel-manager.sh --view-config

# 服務控制
sudo ./trusttunnel-manager.sh --start
sudo ./trusttunnel-manager.sh --stop
sudo ./trusttunnel-manager.sh --restart

# 移除
sudo ./trusttunnel-manager.sh --uninstall-endpoint
sudo ./trusttunnel-manager.sh --uninstall-client

# 幫助
./trusttunnel-manager.sh --help
```

## 系統需求

- **作業系統**: Linux (推薦) / macOS
- **權限**: root (sudo)
- **依賴**: curl, systemd (Linux)

## 目錄結構

安裝後的檔案位置：

```
/opt/trusttunnel/              # Endpoint 安裝目錄
├── trusttunnel_endpoint       # 主程式
├── setup_wizard               # 配置精靈
├── vpn.toml                   # VPN 配置
├── hosts.toml                 # TLS 主機配置
└── trusttunnel.service.template

/opt/trusttunnel_client/       # Client 安裝目錄
├── trusttunnel_client         # 主程式
├── setup_wizard               # 配置精靈
└── trusttunnel_client.toml    # 客戶端配置
```

## 關於 TrustTunnel

TrustTunnel 是一個現代化的開源 VPN 協定，特點：

- 流量偽裝成普通 HTTPS 流量，難以被偵測和封鎖
- 支援 HTTP/1.1、HTTP/2、QUIC 協定
- 可隧道 TCP、UDP、ICMP 流量
- 支援分流 (Split Tunneling) 和自訂 DNS

更多資訊：[TrustTunnel GitHub](https://github.com/TrustTunnel/TrustTunnel)

## 授權

MIT License
