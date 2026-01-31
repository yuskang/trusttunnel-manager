# TrustTunnel Manager

[![CI](https://github.com/yuskang/trusttunnel-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/yuskang/trusttunnel-manager/actions/workflows/ci.yml)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yuskang/trusttunnel-manager/releases/tag/v1.0.0)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)

[繁體中文](README.zh-TW.md) | English

One-click management script for installing, configuring, and managing [TrustTunnel](https://github.com/TrustTunnel/TrustTunnel) VPN protocol.

## Features

| Feature | Description |
|---------|-------------|
| **Install** | Endpoint (server) / Client / Specific version |
| **View Config** | View vpn.toml, hosts.toml, trusttunnel_client.toml |
| **Edit Config** | Setup wizard / Manual edit (auto-backup) / Export client config |
| **Uninstall** | Complete removal with optional config backup |
| **Status Check** | Installation status, service status, config files, network, processes |
| **Service Control** | Start/Stop/Restart/Enable on boot (Linux systemd) |

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/yuskang/trusttunnel-manager/main/dist/trusttunnel-manager.sh -o trusttunnel-manager.sh
chmod +x trusttunnel-manager.sh
sudo ./trusttunnel-manager.sh
```

## Usage

### Interactive Menu

```bash
sudo ./trusttunnel-manager.sh
```

### Command Line Arguments

```bash
# Install
sudo ./trusttunnel-manager.sh --install-endpoint
sudo ./trusttunnel-manager.sh --install-client

# Status & Config
sudo ./trusttunnel-manager.sh --status
sudo ./trusttunnel-manager.sh --view-config

# Service Control
sudo ./trusttunnel-manager.sh --start
sudo ./trusttunnel-manager.sh --stop
sudo ./trusttunnel-manager.sh --restart

# Uninstall
sudo ./trusttunnel-manager.sh --uninstall-endpoint
sudo ./trusttunnel-manager.sh --uninstall-client

# Help
./trusttunnel-manager.sh --help
```

## System Requirements

- **OS**: Linux (recommended) / macOS
- **Permissions**: root (sudo)
- **Dependencies**: curl, systemd (Linux)

## Directory Structure

Installed file locations:

```
/opt/trusttunnel/              # Endpoint installation directory
├── trusttunnel_endpoint       # Main binary
├── setup_wizard               # Configuration wizard
├── vpn.toml                   # VPN configuration
├── hosts.toml                 # TLS host configuration
└── trusttunnel.service.template

/opt/trusttunnel_client/       # Client installation directory
├── trusttunnel_client         # Main binary
├── setup_wizard               # Configuration wizard
└── trusttunnel_client.toml    # Client configuration
```

## About TrustTunnel

TrustTunnel is a modern open-source VPN protocol featuring:

- Traffic disguised as regular HTTPS traffic, difficult to detect and block
- Supports HTTP/1.1, HTTP/2, QUIC protocols
- Can tunnel TCP, UDP, ICMP traffic
- Supports split tunneling and custom DNS

More info: [TrustTunnel GitHub](https://github.com/TrustTunnel/TrustTunnel)

## Development

### Prerequisites

- [ShellCheck](https://github.com/koalaman/shellcheck) - Shell script static analysis
- [BATS](https://github.com/bats-core/bats-core) - Bash Automated Testing System

### Install Development Dependencies

```bash
# macOS
brew install shellcheck bats-core

# Ubuntu/Debian
sudo apt-get install shellcheck bats
```

### Development Commands

```bash
# Run linting
make lint

# Run tests
make test

# Build single-file distribution
make build

# Run all checks (lint + test + build)
make all

# Clean build artifacts
make clean

# Verify built script
make verify
```

### Project Structure

```
trusttunnel-manager/
├── trusttunnel-manager.sh    # Main entry script
├── lib/                      # Modular function library
│   ├── common.sh             # Constants, colors, utilities
│   ├── install.sh            # Installation functions
│   ├── config.sh             # Configuration management
│   ├── status.sh             # Status checking
│   ├── service.sh            # Service control
│   └── uninstall.sh          # Uninstallation
├── tests/                    # BATS tests
├── scripts/                  # Build scripts
├── dist/                     # Build output
└── Makefile                  # Automation commands
```

### Contributing

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`make all`)
5. Commit your changes (`git commit -m 'feat: add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

MIT License
