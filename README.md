LinuxScripts

Small, practical scripts for Linux.

The goal of this repository is simple: collect useful Linux scripts that automate repetitive tasks without adding unnecessary complexity.

«Small scripts. Useful results. No unnecessary bloat.»

What's Inside

scripts/
├── system-info.sh
├── disk-usage.sh
├── update-system.sh
├── cleanup-cache.sh
└── network-info.sh

Current Scripts

Script| Purpose
"system-info.sh"| Display basic system information
"disk-usage.sh"| Display filesystem disk usage
"update-system.sh"| Update the system using the detected package manager
"cleanup-cache.sh"| Perform conservative temporary-file cleanup
"network-info.sh"| Display network interfaces, routes and DNS information

Installation

Clone the repository:

git clone https://github.com/ashishsinghbora/LinuxScripts.git
cd LinuxScripts

Make the scripts executable:

chmod +x scripts/*.sh

Run a script:

./scripts/system-info.sh

Requirements

The scripts are primarily written for Linux systems using standard command-line utilities.

Some scripts may require:

- "sudo"
- "iproute2"
- "util-linux"
- A supported package manager

Design Goals

LinuxScripts follows a few simple principles:

- Keep scripts small.
- Prefer standard Linux utilities.
- Avoid unnecessary dependencies.
- Fail clearly when something goes wrong.
- Avoid destructive operations by default.
- Make scripts easy to read and modify.
- Support multiple Linux distributions where practical.

Safety

Always read a script before running it, especially when it uses "sudo" or modifies your system.

These scripts are provided as-is. Use them at your own risk.

Contributing

Useful improvements and new scripts are welcome.

When adding a script:

1. Keep it focused on one task.
2. Avoid unnecessary dependencies.
3. Handle errors properly.
4. Document how to use it.
5. Test it on a real Linux system.
6. Explain distribution-specific behavior when applicable.

Roadmap

Phase 1 — Basic Utilities

- [x] System information
- [x] Disk usage
- [x] System update helper
- [x] Basic cleanup
- [x] Network information

Phase 2 — Productivity

- [ ] Backup helper
- [ ] File organizer
- [ ] Find large files
- [ ] Process viewer
- [ ] Port checker
- [ ] Service status helper

Phase 3 — Administration

- [ ] SSH setup helper
- [ ] User audit
- [ ] Service management
- [ ] Log inspection
- [ ] System health check
- [ ] Storage health check

Phase 4 — Advanced

- [ ] Network diagnostics
- [ ] Linux troubleshooting toolkit
- [ ] Hardware information
- [ ] Server maintenance utilities
- [ ] Interactive CLI menu

License

MIT License.
