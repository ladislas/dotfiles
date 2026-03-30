## Why

The bootstrap entrypoint is the highest-risk setup path in the repository, but its current implementation mixes brittle argument parsing, weak rerun behavior, and fuzzy failure handling. We need a smaller, more predictable foundation before layering on more machine setup or CI behavior.

## What Changes

- Refactor `bootstrap.sh` around explicit argument parsing and validation instead of regex checks against flattened arrays.
- Define clearer runtime behavior for dry-run mode, fatal versus non-fatal failures, and prerequisite validation before stateful operations begin.
- Make bootstrap-managed symlink setup rerunnable and convergent so repeated runs do not fail on expected existing state.
- Support redirected user-scoped target paths so bootstrap behavior can be validated safely without touching the operator's real home directory.
- Document the runtime contract shared between `bootstrap.sh` and domain scripts under `scripts/`.
- Preserve the current operating model: one bootstrap entrypoint, targeted setup flags, dry-run support, and end-of-run reporting.

## Capabilities

### New Capabilities

- `bootstrap-foundation`: Defines the bootstrap contract for argument parsing, validation, rerun safety, redirected user-scoped targets, and failure semantics.

### Modified Capabilities

- None.

## Impact

- Affected code: `bootstrap.sh`, `scripts/helpers/*.sh`, and setup scripts that rely on bootstrap runtime globals or symlink helpers.
- Affected systems: local machine bootstrap flows, redirected-home sandbox validation, rerun behavior after partial setup, and CI coverage for bootstrap validation.
- Dependencies: shell runtime behavior on macOS, Homebrew detection/bootstrap, and existing repo-local tooling used to validate shell changes.
