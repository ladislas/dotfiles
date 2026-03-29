# Bootstrap Runtime Contract

This document defines what sourced setup scripts under `scripts/*.sh` may rely on
when they are executed by `bootstrap.sh`.

## Runtime inputs

Bootstrap exports or initializes the following values before domain scripts run:

- `DOTFILES_DIR`: absolute path to the repository root
- `HOME`: active target home directory
- `XDG_CONFIG_HOME`: config root for user-scoped files
- `XDG_DATA_HOME`: data root for user-scoped files
- `BREW_PREFIX`: Homebrew prefix when Homebrew is installed or detected
- `COMPUTER_NAME`: machine name provided through `--computer_name=<value>`
- `DRY_RUN`: `true` when bootstrap is running without mutating the machine
- `BOOTSTRAP_HOME`: redirected home target used for sandbox validation when set
- `ARG_ARRAY`: normalized list of selected setup domain flags

In sandbox mode (`BOOTSTRAP_HOME` set), bootstrap rewrites `HOME`,
`XDG_CONFIG_HOME`, and `XDG_DATA_HOME` to point inside the redirected target.

## Logging and command helpers

Sourced scripts may use these helpers from `scripts/helpers/include.sh`:

- `print_section <message>`: print a section header
- `print_action <message>`: print a step within a section
- `fake_try <command>`: print a dry-run style command preview
- `is_ci`: true when `CI` is set
- `is_dry_run`: true when bootstrap is running in dry-run mode
- `in_sandbox`: true when bootstrap is running with redirected user-scoped paths
- `args_contain <flag>`: true when the normalized execution plan includes a flag

Command execution goes through these helpers from `bootstrap.sh`:

- `try <command...>`: fatal command helper; bootstrap stops immediately on failure
- `try_can_fail <command...>`: recoverable command helper; bootstrap records the
  failure and continues

Use `try` for operations that must succeed for the current domain to remain
trustworthy. Use `try_can_fail` only for optional or best-effort work.

## Sudo expectations

- `bootstrap.sh` acquires sudo before running `--brew` and `--macos`
- `scripts/macos.sh` may assume sudo has already been acquired
- Other domains must request sudo explicitly if they perform privileged work
- Sandbox mode rejects domains that require privileged or system-scoped mutation
  instead of trying to simulate them

## Script boundaries

Sourced domain scripts should:

- treat `HOME` and XDG paths as the only valid user-scoped destinations
- avoid re-parsing raw CLI arguments
- rely on the normalized execution plan and shared helpers instead of regex checks
- avoid writing outside user-scoped paths unless the domain is explicitly
  system-scoped

If a script needs stronger guarantees than this contract provides, update the
contract in the same change instead of relying on hidden globals or side effects.
