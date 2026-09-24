# LinuxScripts

A clean, reliable, beginner-friendly Linux utility toolkit designed for systems administrators, developers, and power users.

> Small scripts. Useful results. Zero unnecessary bloat.

---

## Overview

**LinuxScripts** is a modular collection of well-tested, standalone Bash utilities organized into logical categories. Each script adheres to strict engineering and safety standards:
- Starts with `#!/usr/bin/env bash` and enforces `set -euo pipefail`.
- Supports `--help` / `-h` with consistent documentation.
- Prioritizes read-only inspection; destructive operations require explicit user confirmation or flags.
- Relies on standard Linux userland utilities with graceful dependency detection.
- Includes an interactive terminal dashboard (`bin/linux-toolbox`) to run any tool easily.

---

## Directory Structure

```text
LinuxScripts/
├── bin/
│   └── linux-toolbox                 # Interactive menu front-end
├── scripts/
│   ├── system/                       # Host, health, kernel, boot, and service inspectors
│   ├── storage/                      # Disk usage, large files, inodes, mounts, filesystems, SMART
│   ├── network/                      # Network info, ping, DNS, ports, routes, diagnostics
│   ├── process/                      # Process inspection and safe termination
│   ├── packages/                     # Cross-distro package queries and maintenance
│   ├── hardware/                     # CPU, GPU, memory, USB, PCI, and battery inspection
│   ├── ssh/                          # SSH keys, config validation, host keys, and hardening checks
│   ├── developer/                    # Dev tools, Git, Docker, Python, Node, command checks
│   └── maintenance/                  # Safe cleanup, backups, archive extraction, file organizer, logs
├── tests/
│   ├── test_all.sh                   # Automated validation and linting test harness
│   └── fixtures/                     # Test fixtures
├── .github/
│   └── workflows/
│       └── shellcheck.yml            # CI validation workflow
├── CONTRIBUTING.md                   # Contribution guide
├── LICENSE                           # MIT License
└── SECURITY.md                       # Security reporting policy
```

---

## Supported Distributions & Package Managers

The toolkit automatically detects and adapts to the following distributions and package managers:
- **Arch Linux** (`pacman`)
- **Debian / Ubuntu / Linux Mint** (`apt`)
- **Fedora / RHEL / AlmaLinux / Rocky** (`dnf`)
- **openSUSE** (`zypper`)

If an optional command is missing on a specific platform, scripts fail gracefully with clear installation hints instead of crashing.

---

## Installation & Quick Start

Clone the repository and set executable permissions:

```bash
git clone https://github.com/ashishsinghbora/LinuxScripts.git
cd LinuxScripts
chmod +x bin/linux-toolbox scripts/*/*.sh
```

### Launch Interactive Toolbox

```bash
./bin/linux-toolbox
```

### Run Any Script Directly

Every script is standalone and can be executed directly from anywhere:

```bash
# Check overall system health
./scripts/system/system-health.sh

# Find top 10 largest files in /var/log
./scripts/storage/find-large-files.sh -n 10 -d /var/log

# Run full network diagnostics
./scripts/network/network-diagnostics.sh

# Audit SSH daemon security settings (read-only)
./scripts/ssh/ssh-hardening-check.sh

# Organize loose files in a directory safely (dry-run first)
./scripts/maintenance/file-organizer.sh --dry-run
```

---

## Script Reference Table

| Category | Script | Description | Safety Mode |
|---|---|---|---|
| **System** | `system-info.sh` | OS, kernel, arch, uptime, CPU, memory, and root disk summary | Read-only |
| | `system-health.sh` | Quick CPU, RAM, disk, load average, and service triage | Read-only |
| | `kernel-info.sh` | Kernel version, architecture, and loaded modules | Read-only |
| | `boot-info.sh` | Boot performance and startup times via `systemd-analyze` | Read-only |
| | `failed-services.sh` | Lists systemd units currently in a failed state | Read-only |
| **Storage** | `disk-usage.sh` | Human-readable mounted filesystem utilization | Read-only |
| | `find-large-files.sh` | Locates largest files in specified directories | Read-only |
| | `directory-size.sh` | Calculates directory disk space usage | Read-only |
| | `inode-usage.sh` | Inspects inode allocation and flags >90% exhaustion | Read-only |
| | `mount-info.sh` | Details mounted filesystems and options via `findmnt` | Read-only |
| | `filesystem-info.sh` | Inspects filesystem types, UUIDs, and block devices | Read-only |
| | `disk-health.sh` | SMART health assessment using `smartctl` | Read-only |
| **Network** | `network-info.sh` | IP addresses, interfaces, default gateway, and DNS | Read-only |
| | `ping-test.sh` | ICMP latency and packet loss verification | Read-only |
| | `dns-test.sh` | DNS resolution check via `dig` or `nslookup` | Read-only |
| | `port-check.sh` | TCP port connectivity test against target hosts | Read-only |
| | `route-info.sh` | Displays kernel IP routing tables | Read-only |
| | `internet-test.sh` | Tests WAN internet connectivity | Read-only |
| | `listening-ports.sh` | Lists open listening TCP/UDP ports via `ss` / `netstat` | Read-only |
| | `network-diagnostics.sh`| End-to-end connectivity, DNS, ping, and gateway diagnostics | Read-only |
| **Process** | `process-info.sh` | Top CPU and RAM consuming processes | Read-only |
| | `kill-process.sh` | Safe process termination with prompt and custom signals | Confirmation required |
| **Packages** | `update-system.sh` | Multi-distro package database and package updates | Dry-run available (`-n`) |
| | `install-package.sh` | Installs packages across supported package managers | Prompts before install |
| | `remove-package.sh` | Safely removes packages across supported package managers | Prompts before removal |
| | `search-package.sh` | Queries package repositories for keywords | Read-only |
| | `package-info.sh` | Inspects package details and version metadata | Read-only |
| | `package-manager-info.sh`| Identifies active system package manager and version | Read-only |
| **Hardware** | `hardware-summary.sh`| Aggregates CPU, GPU, memory, disk, and USB information | Read-only |
| | `cpu-info.sh` | CPU model, architecture, cores, sockets, and flags | Read-only |
| | `gpu-info.sh` | PCI graphics adapters and OpenGL renderers | Read-only |
| | `memory-info.sh` | Detailed RAM usage and `/proc/meminfo` metrics | Read-only |
| | `usb-devices.sh` | Enumerates attached USB devices via `lsusb` or sysfs | Read-only |
| | `pci-devices.sh` | Lists all detected PCI devices via `lspci` | Read-only |
| | `battery-info.sh` | Power supply and battery capacity/status | Read-only |
| **SSH** | `ssh-key-setup.sh` | Secure Ed25519/RSA key generator with overwrite protection | Confirmation required |
| | `ssh-config-check.sh` | Validates client SSH configuration (`~/.ssh/config`) | Read-only |
| | `ssh-host-info.sh` | Queries remote host fingerprints via `ssh-keyscan` | Read-only |
| | `ssh-hardening-check.sh`| Security audit of `sshd_config` against best practices | Read-only (never edits) |
| **Developer**| `dev-environment-info.sh`| Overview of installed compilers, runtimes, and tools | Read-only |
| | `git-info.sh` | Git version, global user config, and repo working tree | Read-only |
| | `docker-info.sh` | Docker daemon status, containers, and images | Read-only |
| | `python-info.sh` | Python 3 version, virtual environment, and pip packages | Read-only |
| | `node-info.sh` | Node.js, npm, and global package modules | Read-only |
| | `command-exists.sh` | Verifies binary availability across `$PATH` | Read-only |
| **Maintenance**| `cleanup-cache.sh` | Cleans user caches and logs safely | Confirmation required |
| | `backup.sh` | Creates compressed `.tar.gz` archives of directories | Safe write |
| | `extract.sh` | Universal archive unpacker (`tar`, `zip`, `gz`, `bz2`, `xz`, `7z`) | Safe write |
| | `file-organizer.sh` | Categorizes loose files by extension | Dry-run available (`-n`) |
| | `log-inspect.sh` | Inspects and filters system and application logs | Read-only |

---

## Safety Philosophy

- **Zero Hidden Actions:** Every script clearly describes what it does before taking action.
- **Read-Only by Default:** All diagnostics, audits, and hardware/system inspectors never alter files or configs.
- **Protection for Destructive Steps:** Operations that delete caches or terminate processes (`kill-process.sh`, `cleanup-cache.sh`, `remove-package.sh`) require interactive confirmation unless explicit override flags are supplied.
- **SSH Hardening is Advisory:** `ssh-hardening-check.sh` will **never** alter or overwrite `sshd_config`. It only highlights recommendations.
- **Safe Path Handling:** All scripts use proper quoting (`"$variable"`) to avoid space-splitting and injection bugs.

---

## Testing & Quality Assurance

The repository includes an automated validation test suite in `tests/test_all.sh`.

Run the test suite locally:

```bash
bash tests/test_all.sh
```

What the test suite checks:
1. **Syntax:** Executes `bash -n` on every script.
2. **Linting:** Runs `shellcheck` when installed.
3. **Permissions:** Confirms executable bits are set.
4. **Help Flag:** Verifies that every script responds to `-h` or `--help` and exits with status `0`.

---

## Limitations

- **Systemd vs Non-Systemd:** Scripts like `boot-info.sh` and `failed-services.sh` rely on `systemd`. On runit, openrc, or SysVinit systems, these will report that systemd is unavailable.
- **Root Permissions:** Read-only inspection commands run without elevated privileges. Commands requiring root privileges (e.g., package installation, SMART tests via `smartctl`) will prompt for `sudo` only when strictly required.

---

## License

This project is licensed under the [MIT License](LICENSE).
