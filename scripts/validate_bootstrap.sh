#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
SANDBOX_HOME="$WORK_DIR/home"

cleanup() {
  rm -rf "$WORK_DIR"
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

check() {
  printf '  • %s\n' "$1"
}

pass() {
  printf '    ✓ %s\n' "$1"
}

section() {
  printf '\n── %s\n' "$1"
}

assert_symlink_target() {
  local path="$1"
  local expected_target="$2"

  [ -L "$path" ] || fail "$path is not a symlink"
  [ "$path" -ef "$expected_target" ] || fail "$path does not resolve to $expected_target"
}

trap cleanup EXIT

mkdir -p "$SANDBOX_HOME/.config/git" "$SANDBOX_HOME/.local/share/pandoc"
printf 'preexisting git config\n' >"$SANDBOX_HOME/.config/git/config"
printf 'preexisting pandoc file\n' >"$SANDBOX_HOME/.local/share/pandoc/custom-reference.txt"
printf 'root = true\n' >"$SANDBOX_HOME/.editorconfig"

section 'Symlink creation and conflict backup (first run)'
check 'running bootstrap --git --data --dev with pre-existing files'
BOOTSTRAP_HOME="$SANDBOX_HOME" zsh "$ROOT_DIR/bootstrap.sh" --git --data --dev >"$WORK_DIR/first-run.log" 2>&1
pass 'bootstrap exited successfully'

check '.config/git is a symlink to the repo git dir'
assert_symlink_target "$SANDBOX_HOME/.config/git" "$ROOT_DIR/git"
pass '.config/git → ok'

check '.local/share/pandoc is a symlink to the repo data/pandoc dir'
assert_symlink_target "$SANDBOX_HOME/.local/share/pandoc" "$ROOT_DIR/data/pandoc"
pass '.local/share/pandoc → ok'

check '.editorconfig is a symlink to the repo symlink/.editorconfig'
assert_symlink_target "$SANDBOX_HOME/.editorconfig" "$ROOT_DIR/symlink/.editorconfig"
pass '.editorconfig → ok'

check 'conflicting git target was backed up'
find "$SANDBOX_HOME/.config/.bootstrap-backup" -name 'git.*' | grep -q . || fail 'missing backup for conflicting git target'
pass 'git backup → ok'

check 'conflicting pandoc target was backed up'
find "$SANDBOX_HOME/.local/share/.bootstrap-backup" -name 'pandoc.*' | grep -q . || fail 'missing backup for conflicting pandoc target'
pass 'pandoc backup → ok'

check 'conflicting .editorconfig was backed up'
find "$SANDBOX_HOME/.bootstrap-backup" -name '.editorconfig.*' | grep -q . || fail 'missing backup for conflicting editorconfig target'
pass '.editorconfig backup → ok'

section 'Idempotency (second run)'
check 'running bootstrap --git --data --dev again on already-linked home'
BOOTSTRAP_HOME="$SANDBOX_HOME" zsh "$ROOT_DIR/bootstrap.sh" --git --data --dev >"$WORK_DIR/second-run.log" 2>&1
pass 'second run exited successfully'

check 'symlinks still correct after second run'
assert_symlink_target "$SANDBOX_HOME/.config/git" "$ROOT_DIR/git"
assert_symlink_target "$SANDBOX_HOME/.local/share/pandoc" "$ROOT_DIR/data/pandoc"
assert_symlink_target "$SANDBOX_HOME/.editorconfig" "$ROOT_DIR/symlink/.editorconfig"
pass 'all symlinks stable → ok'

section 'Sandbox blocking'
check '--brew is rejected when BOOTSTRAP_HOME is set'
if BOOTSTRAP_HOME="$SANDBOX_HOME" zsh "$ROOT_DIR/bootstrap.sh" --brew >"$WORK_DIR/sandbox-block.log" 2>&1; then
  fail 'sandbox run unexpectedly allowed --brew'
fi
grep -q 'Unsupported args: --brew' "$WORK_DIR/sandbox-block.log" || fail 'sandbox rejection message missing for --brew'
pass '--brew blocked with correct message → ok'

section 'Argument validation'
check 'unrecognized flag --wat is rejected'
if zsh "$ROOT_DIR/bootstrap.sh" --wat >"$WORK_DIR/invalid-arg.log" 2>&1; then
  fail 'unsupported flag unexpectedly succeeded'
fi
grep -q 'Unrecognized argument: --wat' "$WORK_DIR/invalid-arg.log" || fail 'unsupported flag error message missing'
pass '--wat rejected with correct message → ok'

check '--macos without --computer_name is rejected'
if zsh "$ROOT_DIR/bootstrap.sh" --dry-run --macos >"$WORK_DIR/macos-validation.log" 2>&1; then
  fail '--macos without --computer_name unexpectedly succeeded'
fi
grep -q -- '--macos requires a computer name' "$WORK_DIR/macos-validation.log" || fail 'missing macOS validation error'
pass '--macos without name rejected with correct message → ok'

section 'Recoverable failure reporting'
check '--hello reports failed commands without aborting'
zsh "$ROOT_DIR/bootstrap.sh" --hello >"$WORK_DIR/hello.log" 2>&1
grep -q 'The following commands have failed but it' "$WORK_DIR/hello.log" || fail 'recoverable failure summary missing for --hello'
pass 'recoverable failure summary present → ok'

section 'Dry-run mode'
check '--dry-run --git --data --dev creates no symlinks'
DRY_HOME="$WORK_DIR/dry-home"
BOOTSTRAP_HOME="$DRY_HOME" zsh "$ROOT_DIR/bootstrap.sh" --dry-run --git --data --dev >"$WORK_DIR/dry-run.log" 2>&1
[ ! -L "$DRY_HOME/.config/git" ]           || fail '.config/git was created despite --dry-run'
[ ! -L "$DRY_HOME/.local/share/pandoc" ]   || fail '.local/share/pandoc was created despite --dry-run'
[ ! -L "$DRY_HOME/.editorconfig" ]         || fail '.editorconfig was created despite --dry-run'
pass 'no symlinks created in dry-run mode → ok'

printf '\n── All checks passed ✓\n'
