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
  local target="$1"
  local expected_target="$2"

  [ -L "$target" ] || fail "$target is not a symlink"
  [ "$target" -ef "$expected_target" ] || fail "$target does not resolve to $expected_target"
}

trap cleanup EXIT

mkdir -p "$SANDBOX_HOME/.config/git" "$SANDBOX_HOME/.local/share/pandoc" "$SANDBOX_HOME/.gnupg"
printf 'preexisting git config\n' >"$SANDBOX_HOME/.config/git/config"
printf 'preexisting pandoc file\n' >"$SANDBOX_HOME/.local/share/pandoc/custom-reference.txt"
printf 'root = true\n' >"$SANDBOX_HOME/.editorconfig"
printf 'default-cache-ttl 600\n' >"$SANDBOX_HOME/.gnupg/gpg-agent.conf"

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

check '.gnupg/gpg-agent.conf is a symlink to the repo gnupg/gpg-agent.conf'
assert_symlink_target "$SANDBOX_HOME/.gnupg/gpg-agent.conf" "$ROOT_DIR/gnupg/gpg-agent.conf"
pass '.gnupg/gpg-agent.conf → ok'

check 'conflicting gpg-agent.conf target was backed up'
find "$SANDBOX_HOME/.gnupg/.bootstrap-backup" -name 'gpg-agent.conf.*' | grep -q . || fail 'missing backup for conflicting gpg-agent.conf target'
pass 'gpg-agent.conf backup → ok'

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
assert_symlink_target "$SANDBOX_HOME/.gnupg/gpg-agent.conf" "$ROOT_DIR/gnupg/gpg-agent.conf"
pass 'all symlinks stable → ok'

section 'Neovim bootstrap rerun safety'
check 'running bootstrap --nvim twice with a stubbed git clone'
NVIM_HOME="$WORK_DIR/nvim-home"
GIT_STUB_DIR="$WORK_DIR/git-stub"
GIT_STUB_LOG="$WORK_DIR/git-stub.log"
mkdir -p "$GIT_STUB_DIR"
cat >"$GIT_STUB_DIR/.zshenv" <<'EOF'
function git {
  print -r -- "$*" >>"${GIT_STUB_LOG:?}"

  if [ "$1" = "clone" ]; then
    mkdir -p "$4"
    return 0
  fi

  print -u2 -- "unexpected git invocation: $*"
  return 1
}
EOF
ZDOTDIR="$GIT_STUB_DIR" GIT_STUB_LOG="$GIT_STUB_LOG" BOOTSTRAP_HOME="$NVIM_HOME" zsh "$ROOT_DIR/bootstrap.sh" --nvim >"$WORK_DIR/nvim-first-run.log" 2>&1
ZDOTDIR="$GIT_STUB_DIR" GIT_STUB_LOG="$GIT_STUB_LOG" BOOTSTRAP_HOME="$NVIM_HOME" zsh "$ROOT_DIR/bootstrap.sh" --nvim >"$WORK_DIR/nvim-second-run.log" 2>&1
pass '--nvim succeeded twice → ok'

check 'neovim clone runs only once and second run skips cleanly'
[ -d "$NVIM_HOME/.config/nvim" ] || fail 'missing neovim checkout after first run'
[ "$(grep -c '^clone ' "$GIT_STUB_LOG")" -eq 1 ] || fail 'expected exactly one git clone invocation for --nvim'
grep -q 'Neovim config already exists' "$WORK_DIR/nvim-second-run.log" || fail 'missing skip message on second --nvim run'
pass '--nvim rerun safety → ok'

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

section 'Dock manifest failure reporting'
check 'apps_config reports missing Dock manifest failures clearly'
DOCK_TEST_ROOT="$WORK_DIR/dock-test"
mkdir -p "$DOCK_TEST_ROOT/scripts/helpers" "$DOCK_TEST_ROOT/scripts" "$DOCK_TEST_ROOT/bin"
ln -s "$ROOT_DIR/scripts/apps_config.sh" "$DOCK_TEST_ROOT/scripts/apps_config.sh"
ln -s "$ROOT_DIR/scripts/dock.sh" "$DOCK_TEST_ROOT/scripts/dock.sh"
ln -s "$ROOT_DIR/scripts/helpers/include.sh" "$DOCK_TEST_ROOT/scripts/helpers/include.sh"
ln -s "$ROOT_DIR/scripts/helpers/try.sh" "$DOCK_TEST_ROOT/scripts/helpers/try.sh"
cat >"$DOCK_TEST_ROOT/scripts/desktop_state.sh" <<'EOF'
#!/usr/bin/env zsh
typeset -ga managed_desktop_bootstrap_apps=()
function managed_desktop_has_app { return 1 }
function managed_desktop_bootstrap_root_missing { return 1 }
function managed_desktop_quit_app { return 0 }
function managed_desktop_sync_roots { return 0 }
EOF
cat >"$DOCK_TEST_ROOT/bin/dockutil" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$DOCK_TEST_ROOT/bin/dockutil"
cat >"$DOCK_TEST_ROOT/run.zsh" <<EOF
#!/usr/bin/env zsh
typeset -gx DOTFILES_DIR="$DOCK_TEST_ROOT"
typeset -gx HOME="$WORK_DIR/dock-home"
typeset -gx TEMP_FILE="\$(mktemp)"
typeset -ga FAILED_COMMANDS=()
typeset -ga CAN_FAIL_COMMANDS=()
source "\$DOTFILES_DIR/scripts/helpers/include.sh"
function try {
  . "\$DOTFILES_DIR/scripts/helpers/try.sh" "\$@"
}
alias try_can_fail='try -x'
export PATH="$DOCK_TEST_ROOT/bin:/usr/bin:/bin"
mkdir -p "\$HOME"
source "\$DOTFILES_DIR/scripts/apps_config.sh"
EOF
if zsh "$DOCK_TEST_ROOT/run.zsh" >"$WORK_DIR/dock-failure.log" 2>&1; then
  fail 'apps_config unexpectedly succeeded without a Dock manifest'
fi
grep -q 'Dock manifest not found' "$WORK_DIR/dock-failure.log" || fail 'missing Dock manifest error output'
grep -q 'The following commands have failed' "$WORK_DIR/dock-failure.log" || fail 'missing failed command summary for Dock manifest failure'
grep -q 'apply_dock_manifest' "$WORK_DIR/dock-failure.log" || fail 'missing apply_dock_manifest failure entry'
! grep -q 'command not found: print_error' "$WORK_DIR/dock-failure.log" || fail 'unexpected print_error shell failure present'
pass 'Dock manifest failure is explicit and summarized → ok'

section 'Dry-run mode'
check '--dry-run --git --data --dev creates no symlinks'
DRY_HOME="$WORK_DIR/dry-home"
BOOTSTRAP_HOME="$DRY_HOME" zsh "$ROOT_DIR/bootstrap.sh" --dry-run --git --data --dev >"$WORK_DIR/dry-run.log" 2>&1
pass 'bootstrap exited cleanly in dry-run mode'
[ ! -L "$DRY_HOME/.config/git" ]           || fail '.config/git was created despite --dry-run'
[ ! -L "$DRY_HOME/.local/share/pandoc" ]   || fail '.local/share/pandoc was created despite --dry-run'
[ ! -L "$DRY_HOME/.editorconfig" ]         || fail '.editorconfig was created despite --dry-run'
pass 'no symlinks created in dry-run mode → ok'

printf '\n── All checks passed ✓\n'
