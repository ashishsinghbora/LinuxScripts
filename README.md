# LinuxScripts

A clean, reliable, beginner-friendly Linux utility toolkit designed for systems administrators, developers, and power users.

> Small scripts. Useful results. Zero unnecessary bloat.

---

## Overview

**LinuxScripts** is a modular collection of well-tested, standalone Bash utilities organized into logical categories. Each script adheres to strict engineering and safety standards:
- Starts with `#!/usr/bin/env bash` and enforces `set -euo pipefail`.
- Supports `--help` / `-h` with consistent documentation and examples.
- Prioritizes read-only inspection; destructive operations require explicit user confirmation or flags.
- Relies on standard Linux userland utilities with graceful dependency detection.
- Includes a CLI dispatcher and interactive terminal dashboard (`bin/linux-toolbox`) to run any tool easily.
- Backed by an automated 53-point behavioral test suite run across multiple Linux distribution containers.

---

## Directory Structure

```text
LinuxScripts/
├── bin/
│   └── linux-toolbox                 # CLI dispatcher and interactive menu
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
│   ├── test_all.sh                   # Comprehensive test harness (syntax, lint, permissions, functional)
│   ├── functional_test.sh            # Isolated behavioral and security assertion test suite
│   └── fixtures/                     # Test fixtures
├── .github/
│   └── workflows/
│       └── shellcheck.yml            # Multi-distro CI workflow (Ubuntu, Fedora, Arch, Alpine)
├── CONTRIBUTING.md                   # Contribution guide
├── LICENSE                           # MIT License
└── SECURITY.md                       # Security reporting policy
```

---

## Supported Distributions & Package Managers

The toolkit automatically detects and adapts to the following distributions and package managers:
- **Arch Linux** (`pacman`)
- **Debian / Ubuntu / Linux Mint** (`apt` / `apt-get`)
- **Fedora / RHEL / AlmaLinux / Rocky** (`dnf`)
- **openSUSE** (`zypper`)
- **Alpine Linux** (`apk`)

If an optional command is missing on a specific platform, scripts fail gracefully with clear installation hints instead of crashing.

---

## Installation & Quick Start

Clone the repository and set executable permissions:

```bash
git clone https://github.com/ashishsinghbora/LinuxScripts.git
cd LinuxScripts
chmod +x bin/linux-toolbox scripts/*/*.sh tests/*.sh
```

### Linux Toolbox CLI & Interactive Menu

The `linux-toolbox` binary acts both as an interactive menu and a CLI dispatcher:

```bash
# Launch interactive keyboard menu
./bin/linux-toolbox

# List all available categories and utilities
./bin/linux-toolbox list

# Run a utility directly by category/name
./bin/linux-toolbox developer/command-exists bash

# Run a utility with arguments
./bin/linux-toolbox storage/directory-size -d /var/log
```

### Run Any Script Directly

Every script is standalone and can be executed directly from anywhere:

```bash
# Check overall system health
./scripts/system/system-health.sh

# Find top 10 largest files in /var/log
./scripts/storage/find-large-files.sh -n 10 -d /var/log

# Run full network diagnostics with status badges [PASS/FAIL/SKIPPED/UNKNOWN]
./scripts/network/network-diagnostics.sh

# Audit SSH daemon security settings (read-only)
./scripts/ssh/ssh-hardening-check.sh

# Safely extract archive with Zip Slip and traversal protection
./scripts/maintenance/extract.sh archive.tar.gz ./output

# Create timestamped backup with automatic destination exclusion
./scripts/maintenance/backup.sh -d ./myproject -o ./backups

# Organize loose files in a directory safely (dry-run first)
./scripts/maintenance/file-organizer.sh --dry-run -d ~/Downloads
```

---

## Script Reference Table

| Category | Script | Description | Safety Mode |
|---|---|---|---|
| **System** | `system-info.sh` | OS, kernel, arch, uptime, CPU, memory, and root disk summary | Read-only |
| | `system-health.sh` | Quick CPU, RAM, disk, load average, and process triage | Read-only |
| | `kernel-info.sh` | Kernel version, loaded modules (`lsmod` / `/proc/modules`), and config | Read-only |
| | `boot-info.sh` | Boot performance via `systemd-analyze` and logs (graceful container fallback) | Read-only |
| | `failed-services.sh` | Lists systemd units currently in a failed state | Read-only |
| **Storage** | `disk-usage.sh` | Human-readable mounted filesystem utilization | Read-only |
| | `find-large-files.sh` | Locates largest files in specified directories | Read-only |
| | `directory-size.sh` | Calculates human-readable directory disk space usage (`-d / --dir`) | Read-only |
| | `inode-usage.sh` | Inspects inode allocation and flags >90% exhaustion | Read-only |
| | `mount-info.sh` | Details mounted filesystems and options via `findmnt` | Read-only |
| | `filesystem-info.sh` | Inspects filesystem types, UUIDs, block devices, and ext* stats | Read-only |
| | `disk-health.sh` | S.M.A.R.T. health assessment using `smartctl` with device targeting | Read-only |
| **Network** | `network-info.sh` | IP addresses, interfaces, default gateway, and DNS | Read-only |
| | `ping-test.sh` | ICMP latency and packet loss verification | Read-only |
| | `dns-test.sh` | DNS resolution check via `dig` or `nslookup` | Read-only |
| | `port-check.sh` | TCP port connectivity test against target hosts | Read-only |
| | `route-info.sh` | Displays kernel IP routing tables | Read-only |
| | `internet-test.sh` | Tests WAN internet connectivity | Read-only |
| | `listening-ports.sh` | Lists open listening TCP/UDP ports via `ss` / `netstat` | Read-only |
| | `network-diagnostics.sh`| Connectivity, DNS, ping, and gateway diagnostics with status badges | Read-only |
| **Process** | `process-info.sh` | Process status by PID, process search, user filter, or top CPU/RAM | Read-only |
| | `kill-process.sh` | Process termination guarding against PID 1, self ($$), and parent ($PPID) | Confirmation required |
| **Packages** | `update-system.sh` | Updates system across pacman, apt, dnf, zypper, and apk | Dry-run available (`-n`) |
| | `install-package.sh` | Array-safe package installation with dry-run support | Prompts before install |
| | `remove-package.sh` | Array-safe package removal with dry-run support | Prompts before removal |
| | `search-package.sh` | Queries package repositories across all supported package managers | Read-only |
| | `package-info.sh` | Package details and version metadata with sync database fallback | Read-only |
| | `package-manager-info.sh`| Identifies active system package manager and version | Read-only |
| **Hardware** | `hardware-summary.sh`| Aggregates CPU, GPU, memory, disk, and USB information | Read-only |
| | `cpu-info.sh` | CPU model, architecture, cores, sockets, and flags | Read-only |
| | `gpu-info.sh` | PCI graphics adapters and OpenGL renderers | Read-only |
| | `memory-info.sh` | Detailed RAM usage and `/proc/meminfo` metrics | Read-only |
| | `usb-devices.sh` | Enumerates attached USB devices via `lsusb` or sysfs | Read-only |
| | `pci-devices.sh` | Lists all detected PCI devices via `lspci` | Read-only |
| | `battery-info.sh` | Power supply and battery capacity/status | Read-only |
| **SSH** | `ssh-key-setup.sh` | Ed25519/RSA-4096 key generator with automatic backup on overwrite | Confirmation required |
| | `ssh-config-check.sh` | Validates client SSH configuration (`~/.ssh/config`) | Read-only |
| | `ssh-host-info.sh` | Queries remote host fingerprints via `ssh-keyscan` | Read-only |
| | `ssh-hardening-check.sh`| Security audit of `sshd_config` against best practices | Read-only (never edits) |
| **Developer**| `dev-environment-info.sh`| Overview of installed compilers, runtimes, and tools | Read-only |
| | `git-info.sh` | Git version, global user config, and repo working tree | Read-only |
| | `docker-info.sh` | Docker daemon status, containers, and images | Read-only |
| | `python-info.sh` | Python 3 version, virtual environment, and pip packages | Read-only |
| | `node-info.sh` | Node.js, npm, and global package modules | Read-only |
| | `command-exists.sh` | Verifies binary availability across `$PATH` | Read-only |
| **Maintenance**| `cleanup-cache.sh` | Safe user thumbnail/trash cleanup and package manager cache reporting | Confirmation required |
| | `backup.sh` | Creates compressed `.tar.gz` with destination recursion exclusion | Safe write |
| | `extract.sh` | Unpacker with Zip Slip and path traversal (`../`) protection | Safe write |
| | `file-organizer.sh` | Categorizes loose files by extension (skips symlinks/hidden/collisions) | Dry-run available (`-n`) |
| | `log-inspect.sh` | Inspects and filters system and application logs | Read-only |

---

## Safety & Security Engineering

- **Path Traversal & Archive Security:** `extract.sh` validates all archive entries before extraction, rejecting relative path traversal (`../`) and absolute paths (`/etc/...`).
- **Backup Recursion Prevention:** `backup.sh` automatically computes relative paths and excludes destination directories situated inside the source directory, preventing infinite archive bloat. Includes failure cleanup traps.
- **Process Termination Safeguards:** `kill-process.sh` strictly forbids sending signals to PID 1 (init/systemd), PID 0, the script itself (`$$`), or its parent process (`$PPID`).
- **Cache Cleaning Protection:** `cleanup-cache.sh` eliminates arbitrary deletions of `/tmp` sockets/locks, safely targeting only user thumbnail caches and trash directories with interactive confirmation.
- **SSH Key Overwrite Safety:** `ssh-key-setup.sh` generates modern Ed25519 keys, sets strict 0700/0600 permissions, and creates timestamped `.bak_*` backups before replacing existing keys.
- **Array-Based Command Execution:** Package manager scripts invoke commands via Bash arrays (`"${CMD[@]}"`) rather than evaluated strings, preventing argument word-splitting bugs.

---

## Testing & Quality Assurance

The repository includes a comprehensive two-tier test framework:

```bash
# Run full static analysis, ShellCheck, and behavioral tests
bash tests/test_all.sh

# Run behavioral assertion suite directly
bash tests/functional_test.sh
```

What the test framework verifies:
1. **Syntax Validation:** Executes `bash -n` on all 34 scripts.
2. **Linting:** Enforces strict ShellCheck rules with zero warnings.
3. **Executable Bit:** Verifies executable file permissions.
4. **Interface Consistency:** Tests `--help` and `-h` across every utility.
5. **Behavioral Assertions:** Runs 53 isolated functional tests using temporary workspaces (`mktemp`), mock package managers, simulated archives, and controlled processes.
6. **Continuous Integration:** Automatically tested on every push and PR across Ubuntu 24.04, Fedora, Arch Linux, and Alpine Linux container environments.

---

## License

This project is licensed under the [MIT License](LICENSE).
