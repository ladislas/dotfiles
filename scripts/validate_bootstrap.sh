#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
SANDBOX_HOME="$WORK_DIR/home"

cleanup() {
  rm -rf "$WORK_DIR"
}

fail() {
  printf 'Validation failed: %s\n' "$1" >&2
  exit 1
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

BOOTSTRAP_HOME="$SANDBOX_HOME" zsh "$ROOT_DIR/bootstrap.sh" --git --data --dev >"$WORK_DIR/first-run.log" 2>&1
assert_symlink_target "$SANDBOX_HOME/.config/git" "$ROOT_DIR/git"
assert_symlink_target "$SANDBOX_HOME/.local/share/pandoc" "$ROOT_DIR/data/pandoc"
assert_symlink_target "$SANDBOX_HOME/.editorconfig" "$ROOT_DIR/symlink/.editorconfig"

backup_dir="$SANDBOX_HOME/.config/.bootstrap-backup"
find "$backup_dir" -name 'git.*' | grep -q . || fail 'missing backup for conflicting git target'
backup_dir="$SANDBOX_HOME/.local/share/.bootstrap-backup"
find "$backup_dir" -name 'pandoc.*' | grep -q . || fail 'missing backup for conflicting pandoc target'
backup_dir="$SANDBOX_HOME/.bootstrap-backup"
find "$backup_dir" -name '.editorconfig.*' | grep -q . || fail 'missing backup for conflicting editorconfig target'

BOOTSTRAP_HOME="$SANDBOX_HOME" zsh "$ROOT_DIR/bootstrap.sh" --git --data --dev >"$WORK_DIR/second-run.log" 2>&1
assert_symlink_target "$SANDBOX_HOME/.config/git" "$ROOT_DIR/git"
assert_symlink_target "$SANDBOX_HOME/.local/share/pandoc" "$ROOT_DIR/data/pandoc"
assert_symlink_target "$SANDBOX_HOME/.editorconfig" "$ROOT_DIR/symlink/.editorconfig"

if BOOTSTRAP_HOME="$SANDBOX_HOME" zsh "$ROOT_DIR/bootstrap.sh" --brew >"$WORK_DIR/sandbox-block.log" 2>&1; then
  fail 'sandbox run unexpectedly allowed --brew'
fi

grep -q 'Unsupported args: --brew' "$WORK_DIR/sandbox-block.log" || fail 'sandbox rejection message missing for --brew'

if zsh "$ROOT_DIR/bootstrap.sh" --wat >"$WORK_DIR/invalid-arg.log" 2>&1; then
  fail 'unsupported flag unexpectedly succeeded'
fi

grep -q 'Unrecognized argument: --wat' "$WORK_DIR/invalid-arg.log" || fail 'unsupported flag error message missing'

if zsh "$ROOT_DIR/bootstrap.sh" --dry-run --macos >"$WORK_DIR/macos-validation.log" 2>&1; then
  fail '--macos without --computer_name unexpectedly succeeded'
fi

grep -q -- '--macos requires a computer name' "$WORK_DIR/macos-validation.log" || fail 'missing macOS validation error'

zsh "$ROOT_DIR/bootstrap.sh" --hello >"$WORK_DIR/hello.log" 2>&1
grep -q 'The following commands have failed but it' "$WORK_DIR/hello.log" || fail 'recoverable failure summary missing for --hello'

printf 'Bootstrap validation passed. Logs kept in %s until exit.\n' "$WORK_DIR"
