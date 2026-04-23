# Project Guidelines

## Repository Overview

Personal macOS dotfiles repository with zsh configuration, git customization, and automated system
setup. Uses [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/)
to keep `$HOME` clean.

## Directory Structure

- `bootstrap.sh` — main entry point, orchestrates all setup
- `scripts/` — individual setup scripts (`brew.sh`, `apps.sh`, `macos.sh`, etc.)
- `scripts/helpers/` — shared utilities (`include.sh`, `try.sh`)
- `zsh/` — ZSH configuration (symlinked to `~/.config/zsh`)
- `git/` — git configuration (symlinked to `~/.config/git`)
- `symlink/` — files symlinked directly to `$HOME`
- `Library/` — macOS application preferences and configs
- `config/` — application-specific configurations
- `data/` — XDG data files (symlinked to `~/.local/share`)
- `openspec/` — OpenSpec change artifacts

## XDG Configuration Flow

```text
$HOME/.zshenv (symlink) → dotfiles/symlink/.zshenv
    ↓ sets ZDOTDIR
$HOME/.config/zsh → dotfiles/zsh/
    ↓ loads
.zshenv → .zshrc → modules/*.zsh
```

ZSH modules live in `zsh/modules/`. Custom functions live in `zsh/functions/`. Machine-local shell
overrides belong in `${XDG_CONFIG_HOME:-$HOME/.config}/zsh/local.zsh` — not in the shared repo
files. Override the path with `ZSH_LOCAL_RC` when a machine needs a different local hook file.

## Bootstrap Safety

The `try` function in `scripts/helpers/try.sh` wraps commands with execution tracking, timing, and
error collection (reported at end of run). Use `try_can_fail` for non-critical operations.

Bootstrap is idempotent. On conflict, existing targets are preserved in sibling `.bootstrap-backup/`
directories rather than overwritten. Use `BOOTSTRAP_HOME=/tmp/test-dir zsh bootstrap.sh ...` to
exercise setup against a redirected home without touching real home targets. `--brew` and
`--apps-config` are blocked when `BOOTSTRAP_HOME` is set.

**macOS cautions:**

- `--macos` requires `--computer_name=<name>` and writes system-level defaults. Run only on the
  intended machine.
- Desktop state (`Library/**`, `config/dock.tsv`) is exported from the main machine via
  `--rsync` and applied elsewhere via `--apps-config`. Do not edit plists directly as a source of
  truth.

## CI

Three jobs run on every push:

- **Lint** — runs `mise run lint` (Markdown + YAML)
- **Validate bootstrap** — runs `zsh scripts/validate_bootstrap.sh` in a sandboxed home
- **Bootstrap integration** — symlink creation, conflict backup, idempotency, sandbox blocking,
  argument validation, and recoverable failure reporting against a real home target

## Git Commits

This repo uses [gitmoji](https://gitmoji.dev). Commit format:

```text
<emoji> (<topic>): <message>
```

Example: `🔧 (tooling): Add mise and hk workflow`

Use the `gitmoji` CLI to find the right emoji: `gitmoji list`

## Git Workflow

### Branch Naming

Branches follow the pattern: `<firstname>/<type>/<topic-more_info>`

- Types: `feature`, `release`, `bugfix`
- Example: `ladislas/feature/setup-mise-hk-linters`

Always create a branch — keep `main` clean.

## OpenSpec

- Use OpenSpec in this repo for meaningful multi-step work, not for tiny obvious edits.
- Keep change artifacts under `openspec/` until the work is complete and ready to archive.
- Commit meaningful OpenSpec artifacts when they preserve rationale and review context.
- Keep the human in the loop: proposal, design, specs, and tasks should guide implementation rather than replace review and judgment.

## Local Tooling

- Trust and install repo-local tools with `mise trust && mise install`
- Run repo checks with `mise run lint`
- Install hooks with `mise run hooks`
- Use `mise run lint:fix` before committing if Markdown lint wants autofixes
