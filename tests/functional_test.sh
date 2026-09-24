#!/usr/bin/env bash
# ==============================================================================
# tests/functional_test.sh
# End-to-end isolated behavioral and security test suite for LinuxScripts.
# Tests actual script execution, edge cases, error conditions, and mocks.
# ==============================================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_TMP="$(mktemp -d)"
trap 'rm -rf "$TEST_TMP"' EXIT

TOTAL=0
PASSED=0
FAILED=0

assert_success() {
  local desc="$1"
  shift
  TOTAL=$((TOTAL + 1))
  if "$@"; then
    echo "  ✅ PASS: $desc"
    PASSED=$((PASSED + 1))
  else
    echo "  ❌ FAIL: $desc"
    FAILED=$((FAILED + 1))
  fi
}

assert_failure() {
  local desc="$1"
  shift
  TOTAL=$((TOTAL + 1))
  if ! "$@" >/dev/null 2>&1; then
    echo "  ✅ PASS: $desc"
    PASSED=$((PASSED + 1))
  else
    echo "  ❌ FAIL: $desc (expected command to fail, but succeeded)"
    FAILED=$((FAILED + 1))
  fi
}

echo "=================================================================="
echo " Starting LinuxScripts Behavioral & Functional Test Suite"
echo " Workspace: $TEST_TMP"
echo "=================================================================="
echo ""

# ----------------------------------------------------------------------
# 1. Developer Utilities
# ----------------------------------------------------------------------
echo "--- 1. Developer Utilities ---"
assert_success "command-exists.sh finds existing 'bash'" \
  "$ROOT_DIR/scripts/developer/command-exists.sh" bash

assert_failure "command-exists.sh fails on nonexistent command" \
  "$ROOT_DIR/scripts/developer/command-exists.sh" nonexistent_command_xyz_12345

assert_success "dev-environment-info.sh runs cleanly" \
  "$ROOT_DIR/scripts/developer/dev-environment-info.sh"

assert_success "git-info.sh runs cleanly" \
  "$ROOT_DIR/scripts/developer/git-info.sh"

assert_success "python-info.sh runs cleanly" \
  "$ROOT_DIR/scripts/developer/python-info.sh"

# ----------------------------------------------------------------------
# 2. System & Storage Info Utilities
# ----------------------------------------------------------------------
echo "--- 2. System & Storage Utilities ---"
assert_success "system-info.sh runs cleanly" \
  "$ROOT_DIR/scripts/system/system-info.sh"

assert_success "kernel-info.sh runs cleanly" \
  "$ROOT_DIR/scripts/system/kernel-info.sh"

assert_success "boot-info.sh runs cleanly" \
  "$ROOT_DIR/scripts/system/boot-info.sh"

assert_success "failed-services.sh runs cleanly" \
  "$ROOT_DIR/scripts/system/failed-services.sh"

assert_success "disk-usage.sh runs cleanly" \
  "$ROOT_DIR/scripts/storage/disk-usage.sh"

assert_success "filesystem-info.sh runs cleanly" \
  "$ROOT_DIR/scripts/storage/filesystem-info.sh"

assert_success "mount-info.sh runs cleanly" \
  "$ROOT_DIR/scripts/storage/mount-info.sh"

DIR_SIZE_TMP="$TEST_TMP/dir_size_test"
mkdir -p "$DIR_SIZE_TMP"
echo "hello world" > "$DIR_SIZE_TMP/file.txt"
assert_success "directory-size.sh measures test directory" \
  "$ROOT_DIR/scripts/storage/directory-size.sh" -d "$DIR_SIZE_TMP"

assert_failure "disk-health.sh rejects invalid non-block device" \
  "$ROOT_DIR/scripts/storage/disk-health.sh" /dev/nonexistent_device_test_xyz

# ----------------------------------------------------------------------
# 3. Archive & Extraction Security (extract.sh)
# ----------------------------------------------------------------------
echo "--- 3. Archive & Extraction Security ---"
EXTRACT_SRC="$TEST_TMP/extract_src"
EXTRACT_DEST="$TEST_TMP/extract_dest"
mkdir -p "$EXTRACT_SRC" "$EXTRACT_DEST"
echo "content" > "$EXTRACT_SRC/sample.txt"
tar -czf "$TEST_TMP/valid.tar.gz" -C "$EXTRACT_SRC" sample.txt

assert_success "extract.sh lists valid archive (-l)" \
  "$ROOT_DIR/scripts/maintenance/extract.sh" -l "$TEST_TMP/valid.tar.gz"

assert_success "extract.sh extracts valid archive" \
  "$ROOT_DIR/scripts/maintenance/extract.sh" "$TEST_TMP/valid.tar.gz" "$EXTRACT_DEST"

# Craft malicious path traversal tar
python3 -c "
import tarfile, io
with tarfile.open('$TEST_TMP/traversal.tar.gz', 'w:gz') as tar:
    data = b'attack'
    ti = tarfile.TarInfo(name='../evil.txt')
    ti.size = len(data)
    tar.addfile(ti, io.BytesIO(data))
"
assert_failure "extract.sh blocks path traversal archive (../evil.txt)" \
  "$ROOT_DIR/scripts/maintenance/extract.sh" "$TEST_TMP/traversal.tar.gz" "$EXTRACT_DEST"

# Craft malicious absolute path tar
python3 -c "
import tarfile, io
with tarfile.open('$TEST_TMP/absolute.tar.gz', 'w:gz') as tar:
    data = b'attack'
    ti = tarfile.TarInfo(name='/tmp/evil.txt')
    ti.size = len(data)
    tar.addfile(ti, io.BytesIO(data))
"
assert_failure "extract.sh blocks absolute path archive (/tmp/evil.txt)" \
  "$ROOT_DIR/scripts/maintenance/extract.sh" "$TEST_TMP/absolute.tar.gz" "$EXTRACT_DEST"

# ----------------------------------------------------------------------
# 4. Backup Safety (backup.sh)
# ----------------------------------------------------------------------
echo "--- 4. Backup Safety ---"
BACKUP_SRC="$TEST_TMP/backup_src with spaces"
mkdir -p "$BACKUP_SRC/nested"
echo "file 1" > "$BACKUP_SRC/data with spaces.txt"
echo "unicode" > "$BACKUP_SRC/nested/テスト.txt"

assert_success "backup.sh creates archive with spaces and Unicode" \
  "$ROOT_DIR/scripts/maintenance/backup.sh" -d "$BACKUP_SRC" -o "$BACKUP_SRC/backups"

BACKUP_ARCHIVE=$(find "$BACKUP_SRC/backups" -name "*.tar.gz" | head -n1)
test -n "$BACKUP_ARCHIVE" && test -f "$BACKUP_ARCHIVE"
assert_success "backup archive file was generated" test -f "$BACKUP_ARCHIVE"

# Ensure nested backups dir was excluded
EXCLUDED_OK=true
if tar -tf "$BACKUP_ARCHIVE" | grep -q "backups/"; then
  EXCLUDED_OK=false
fi
assert_success "backup.sh excludes nested destination directory" $EXCLUDED_OK

assert_failure "backup.sh rejects nonexistent source directory" \
  "$ROOT_DIR/scripts/maintenance/backup.sh" -d "$TEST_TMP/nonexistent_dir"

# ----------------------------------------------------------------------
# 5. File Organizer & Cleanup Safety
# ----------------------------------------------------------------------
echo "--- 5. File Organizer & Cache Cleanup ---"
ORG_TMP="$TEST_TMP/org_test"
mkdir -p "$ORG_TMP/Documents"
echo "existing document" > "$ORG_TMP/Documents/doc.pdf"
echo "new document" > "$ORG_TMP/doc.pdf"
echo "photo" > "$ORG_TMP/image with spaces.png"
echo "unicode photo" > "$ORG_TMP/写真.jpg"
echo "hidden" > "$ORG_TMP/.hidden.txt"
echo "noext" > "$ORG_TMP/plain_file"
ln -s "$ORG_TMP/plain_file" "$ORG_TMP/symlink_file.png"

# Test dry-run
DRY_OUT=$("$ROOT_DIR/scripts/maintenance/file-organizer.sh" -d "$ORG_TMP" --dry-run)
assert_success "file-organizer.sh dry-run prints dry run mode" test -n "$DRY_OUT"
assert_success "file-organizer.sh dry-run preserves file locations" test -f "$ORG_TMP/doc.pdf"

# Run live organizer
"$ROOT_DIR/scripts/maintenance/file-organizer.sh" -d "$ORG_TMP" >/dev/null

assert_success "file-organizer.sh moves image with spaces" test -f "$ORG_TMP/Images/image with spaces.png"
assert_success "file-organizer.sh moves Unicode filename" test -f "$ORG_TMP/Images/写真.jpg"
assert_success "file-organizer.sh does not overwrite destination collision" grep -q "existing document" "$ORG_TMP/Documents/doc.pdf"
assert_success "file-organizer.sh preserves hidden files" test -f "$ORG_TMP/.hidden.txt"
assert_success "file-organizer.sh preserves files without extensions" test -f "$ORG_TMP/plain_file"
assert_success "file-organizer.sh preserves symlinks without moving" test -L "$ORG_TMP/symlink_file.png"

# Cache cleanup in mock home
MOCK_HOME="$TEST_TMP/mock_home"
mkdir -p "$MOCK_HOME/.cache/thumbnails" "$MOCK_HOME/.local/share/Trash/files"
touch "$MOCK_HOME/.cache/thumbnails/test.png" "$MOCK_HOME/.local/share/Trash/files/old.txt"

HOME="$MOCK_HOME" "$ROOT_DIR/scripts/maintenance/cleanup-cache.sh" --dry-run >/dev/null
assert_success "cleanup-cache.sh dry-run preserves thumbnail cache" test -f "$MOCK_HOME/.cache/thumbnails/test.png"

HOME="$MOCK_HOME" "$ROOT_DIR/scripts/maintenance/cleanup-cache.sh" --yes >/dev/null
assert_success "cleanup-cache.sh cleans thumbnail cache" test ! -f "$MOCK_HOME/.cache/thumbnails/test.png"
assert_success "cleanup-cache.sh empties user trash" test ! -f "$MOCK_HOME/.local/share/Trash/files/old.txt"

# ----------------------------------------------------------------------
# 6. Process Management Safety (kill-process.sh, process-info.sh)
# ----------------------------------------------------------------------
echo "--- 6. Process Management Safety ---"
assert_success "process-info.sh queries current PID ($$)" \
  "$ROOT_DIR/scripts/process/process-info.sh" "$$"

assert_failure "process-info.sh fails on invalid PID 9999999" \
  "$ROOT_DIR/scripts/process/process-info.sh" 9999999

assert_failure "kill-process.sh refuses to kill PID 1 (init)" \
  "$ROOT_DIR/scripts/process/kill-process.sh" 1

assert_failure "kill-process.sh refuses to kill self ($$)" \
  "$ROOT_DIR/scripts/process/kill-process.sh" "$$"

sleep 60 &
SLEEP_PID=$!
assert_success "kill-process.sh safely terminates child process with -f" \
  "$ROOT_DIR/scripts/process/kill-process.sh" -f "$SLEEP_PID"
sleep 0.2
assert_failure "child process is no longer running" kill -0 "$SLEEP_PID"

# ----------------------------------------------------------------------
# 7. SSH Key Setup (ssh-key-setup.sh)
# ----------------------------------------------------------------------
echo "--- 7. SSH Key Setup ---"
SSH_HOME="$TEST_TMP/ssh_home"
mkdir -p "$SSH_HOME"

if command -v ssh-keygen >/dev/null 2>&1; then
  HOME="$SSH_HOME" "$ROOT_DIR/scripts/ssh/ssh-key-setup.sh" -p "" -y >/dev/null
  assert_success "ssh-key-setup.sh generates Ed25519 key" test -f "$SSH_HOME/.ssh/id_ed25519"
  assert_success "ssh-key-setup.sh enforces 0700 permission on .ssh" test "$(stat -c "%a" "$SSH_HOME/.ssh")" = "700"
  assert_success "ssh-key-setup.sh enforces 0600 permission on private key" test "$(stat -c "%a" "$SSH_HOME/.ssh/id_ed25519")" = "600"

  assert_failure "ssh-key-setup.sh refuses overwrite without -f" \
    env HOME="$SSH_HOME" "$ROOT_DIR/scripts/ssh/ssh-key-setup.sh" -p ""

  HOME="$SSH_HOME" "$ROOT_DIR/scripts/ssh/ssh-key-setup.sh" -f -y -p "" -c "updated@host" >/dev/null
  BACKUP_KEYS=$(find "$SSH_HOME/.ssh" -name "id_ed25519.pub.bak_*" | wc -l)
  assert_success "ssh-key-setup.sh creates backup before overwrite" test "$BACKUP_KEYS" -ge 1
else
  echo "  ⚠️  ssh-keygen not installed; skipping ssh-key-setup test"
fi

# ----------------------------------------------------------------------
# 8. Package Manager Mock Suite
# ----------------------------------------------------------------------
echo "--- 8. Package Manager Mock Suite ---"
MOCK_BIN="$TEST_TMP/mock_bin"
MOCK_CORE="$TEST_TMP/mock_core"
mkdir -p "$MOCK_BIN" "$MOCK_CORE"

for cmd in sh bash cat echo grep sed head dirname basename tr cut test true false; do
  p="$(command -v "$cmd" 2>/dev/null || true)"
  [[ -n "$p" ]] && ln -s "$p" "$MOCK_CORE/$cmd"
done

# shellcheck disable=SC2317
test_mock_pm() {
  local target_pm="$1"
  local expected_install="$2"
  local expected_remove="$3"
  
  rm -f "$MOCK_BIN"/*
  
  cat << MOCK > "$MOCK_BIN/$target_pm"
#!/usr/bin/env bash
echo "[$target_pm called: \$*]"
MOCK
  chmod +x "$MOCK_BIN/$target_pm"

  PATH="$MOCK_BIN:$MOCK_CORE" "$ROOT_DIR/scripts/packages/package-manager-info.sh" >/dev/null
  PATH="$MOCK_BIN:$MOCK_CORE" "$ROOT_DIR/scripts/packages/search-package.sh" dummy_pkg >/dev/null
  PATH="$MOCK_BIN:$MOCK_CORE" "$ROOT_DIR/scripts/packages/package-info.sh" dummy_pkg >/dev/null
  PATH="$MOCK_BIN:$MOCK_CORE" "$ROOT_DIR/scripts/packages/update-system.sh" --dry-run >/dev/null
  PATH="$MOCK_BIN:$MOCK_CORE" "$ROOT_DIR/scripts/packages/install-package.sh" --dry-run dummy_pkg | grep -q "$expected_install"
  PATH="$MOCK_BIN:$MOCK_CORE" "$ROOT_DIR/scripts/packages/remove-package.sh" --dry-run dummy_pkg | grep -q "$expected_remove"
}

assert_success "mock pacman suite execution" test_mock_pm pacman "pacman -S --noconfirm dummy_pkg" "pacman -R --noconfirm dummy_pkg"
assert_success "mock apt suite execution" test_mock_pm apt "apt install -y dummy_pkg" "apt remove -y dummy_pkg"
assert_success "mock dnf suite execution" test_mock_pm dnf "dnf install -y dummy_pkg" "dnf remove -y dummy_pkg"
assert_success "mock zypper suite execution" test_mock_pm zypper "zypper install -y dummy_pkg" "zypper remove -y dummy_pkg"
assert_success "mock apk suite execution" test_mock_pm apk "apk add dummy_pkg" "apk del dummy_pkg"

# ----------------------------------------------------------------------
# 9. Linux Toolbox CLI Integration (bin/linux-toolbox)
# ----------------------------------------------------------------------
echo "--- 9. Linux Toolbox CLI Integration ---"
assert_success "linux-toolbox --help works" \
  "$ROOT_DIR/bin/linux-toolbox" --help

assert_success "linux-toolbox list works" \
  "$ROOT_DIR/bin/linux-toolbox" list

assert_success "linux-toolbox executes script subcommand" \
  "$ROOT_DIR/bin/linux-toolbox" developer/command-exists bash

assert_failure "linux-toolbox fails on non-existent command" \
  "$ROOT_DIR/bin/linux-toolbox" invalid/nonexistent-script-command

# ----------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------
echo ""
echo "=================================================================="
echo " Functional Test Results: $PASSED / $TOTAL passed"
if [[ $FAILED -gt 0 ]]; then
  echo " ❌ $FAILED test(s) FAILED!"
  echo "=================================================================="
  exit 1
else
  echo " ✅ ALL FUNCTIONAL TESTS PASSED!"
  echo "=================================================================="
  exit 0
fi
