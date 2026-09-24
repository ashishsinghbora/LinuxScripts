# Contributing to LinuxScripts

Thank you for your interest in improving LinuxScripts!

## Principles & Guidelines

1. **Standards:**
   - Every script must start with `#!/usr/bin/env bash` and `set -euo pipefail`.
   - Implement a `--help` / `-h` flag describing usage, options, and dependencies.
   - Quote all variables properly and handle filenames containing spaces safely.
   - Minimize external dependencies; prefer core POSIX / standard Linux utilities.
   - Gracefully detect dependencies using `command -v`.

2. **Safety First:**
   - Default to read-only or dry-run modes where practical.
   - Destructive operations (process termination, package removal, cache clearing) must require explicit user confirmation or flags.
   - Never run unvalidated `rm -rf` commands.
   - SSH audits and checks must remain strictly read-only.

3. **Testing:**
   - Verify syntax: `bash -n <script>`
   - Verify ShellCheck: `shellcheck <script>`
   - Ensure the script has executable permissions (`chmod +x <script>`).
   - Run the automated test suite before opening a pull request:
     ```bash
     bash tests/test_all.sh
     ```

## Submitting Pull Requests

- Keep commits focused, descriptive, and atomic.
- Include an explanation of the change and the testing performed.
- Ensure all tests pass with 0 errors.
