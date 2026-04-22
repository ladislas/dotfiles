#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
WORK_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$WORK_DIR"
}

trap cleanup EXIT

# Guard: CI environments only.
if [ -z "${CI:-}" ]; then
  printf 'ERROR: CI environment variable is not set.\n' >&2
  printf 'bootstrap_integration.sh must run in CI only.\n' >&2
  exit 1
fi

# Guard: refuse to run on a home that already has bootstrap symlinks.
# Pre-seeding writes through existing symlinks into the repo itself.
for path in \
  "$HOME/.config/git" \
  "$HOME/.config/zsh" \
  "$HOME/.local/share/pandoc" \
  "$HOME/.editorconfig" \
  "$HOME/.zshenv"
do
  if [ -L "$path" ]; then
    printf 'ERROR: %s is already a symlink.\n' "$path" >&2
    printf 'bootstrap_integration.sh must run on a clean home (CI only).\n' >&2
    exit 1
  fi
done

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

section 'Setup: pre-seeding conflicting files in real home'
check 'creating conflicting files at bootstrap target locations'
mkdir -p "$HOME/.config/git" "$HOME/.config/zsh" "$HOME/.local/share/pandoc"
printf 'preexisting git config\n'                >"$HOME/.config/git/config"
printf 'preexisting pandoc file\n'               >"$HOME/.local/share/pandoc/custom-reference.txt"
printf 'root = true\n'                           >"$HOME/.editorconfig"
printf 'preexisting zshenv\n'                    >"$HOME/.zshenv"
printf 'preexisting zsh config\n'                >"$HOME/.config/zsh/zshrc"
pass 'conflicting files created'

section 'Symlink creation and conflict backup (first run)'
check 'running bootstrap --git --data --dev --zsh against real home'
zsh "$ROOT_DIR/bootstrap.sh" --git --data --dev --zsh >"$WORK_DIR/first-run.log" 2>&1
pass 'bootstrap exited successfully'

check '.config/git is a symlink to the repo git dir'
assert_symlink_target "$HOME/.config/git" "$ROOT_DIR/git"
pass '.config/git → ok'

check '.local/share/pandoc is a symlink to the repo data/pandoc dir'
assert_symlink_target "$HOME/.local/share/pandoc" "$ROOT_DIR/data/pandoc"
pass '.local/share/pandoc → ok'

check '.editorconfig is a symlink to the repo symlink/.editorconfig'
assert_symlink_target "$HOME/.editorconfig" "$ROOT_DIR/symlink/.editorconfig"
pass '.editorconfig → ok'

check '.zshenv is a symlink to the repo symlink/.zshenv'
assert_symlink_target "$HOME/.zshenv" "$ROOT_DIR/symlink/.zshenv"
pass '.zshenv → ok'

check '.config/zsh is a symlink to the repo zsh dir'
assert_symlink_target "$HOME/.config/zsh" "$ROOT_DIR/zsh"
pass '.config/zsh → ok'

check 'conflicting git target was backed up'
find "$HOME/.config/.bootstrap-backup" -name 'git.*' | grep -q . || fail 'missing backup for conflicting git target'
pass 'git backup → ok'

check 'conflicting pandoc target was backed up'
find "$HOME/.local/share/.bootstrap-backup" -name 'pandoc.*' | grep -q . || fail 'missing backup for conflicting pandoc target'
pass 'pandoc backup → ok'

check 'conflicting .editorconfig was backed up'
find "$HOME/.bootstrap-backup" -name '.editorconfig.*' | grep -q . || fail 'missing backup for conflicting editorconfig target'
pass '.editorconfig backup → ok'

check 'conflicting .zshenv was backed up'
find "$HOME/.bootstrap-backup" -name '.zshenv.*' | grep -q . || fail 'missing backup for conflicting .zshenv target'
pass '.zshenv backup → ok'

check 'conflicting .config/zsh was backed up'
find "$HOME/.config/.bootstrap-backup" -name 'zsh.*' | grep -q . || fail 'missing backup for conflicting .config/zsh target'
pass '.config/zsh backup → ok'

section 'Idempotency (second run)'
check 'running bootstrap --git --data --dev --zsh again on already-linked home'
zsh "$ROOT_DIR/bootstrap.sh" --git --data --dev --zsh >"$WORK_DIR/second-run.log" 2>&1
pass 'second run exited successfully'

check 'symlinks still correct after second run'
assert_symlink_target "$HOME/.config/git" "$ROOT_DIR/git"
assert_symlink_target "$HOME/.local/share/pandoc" "$ROOT_DIR/data/pandoc"
assert_symlink_target "$HOME/.editorconfig" "$ROOT_DIR/symlink/.editorconfig"
assert_symlink_target "$HOME/.zshenv" "$ROOT_DIR/symlink/.zshenv"
assert_symlink_target "$HOME/.config/zsh" "$ROOT_DIR/zsh"
pass 'all symlinks stable → ok'

section 'Sandbox blocking'
check '--brew is rejected when BOOTSTRAP_HOME is set'
SANDBOX_HOME="$(mktemp -d)"
if BOOTSTRAP_HOME="$SANDBOX_HOME" zsh "$ROOT_DIR/bootstrap.sh" --brew >"$WORK_DIR/sandbox-block.log" 2>&1; then
  rm -rf "$SANDBOX_HOME"
  fail 'sandbox run unexpectedly allowed --brew'
fi
rm -rf "$SANDBOX_HOME"
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

printf '\n── All checks passed ✓\n'
