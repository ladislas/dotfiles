## Why

CI currently uses stale GitHub Action versions (`actions/checkout@v2.0.0`, `jdx/mise-action@v2`) and runs ad-hoc bootstrap invocations that don't express the guarantees they're meant to protect. Now that the bootstrap foundation is complete and `scripts/validate_bootstrap.sh` exists, CI can be updated to run contract-based verification instead of informal smoke tests.

## What Changes

- Update `actions/checkout` from `v2.0.0` → `v6` in all jobs
- Update `jdx/mise-action` from `v2` → `v4` in all jobs
- Replace the four outdated bootstrap CI jobs (`bootstrap_all_dry_run`, `bootstrap_quick`, `bootstrap_all`, `bootstrap_rsync_back`) with a single `validate-bootstrap` job that runs `scripts/validate_bootstrap.sh`
- Add `jdx/mise-action` setup to the new validation job (needed for `zsh` resolution on the runner)
- Document explicitly what CI guarantees versus what is excluded from CI

## Capabilities

### New Capabilities

- `ci-bootstrap-verification`: CI runs `scripts/validate_bootstrap.sh` as the authoritative bootstrap contract check, covering idempotency, sandbox blocking, argument validation, and recoverable failure reporting

### Modified Capabilities

- `repository-tooling-baseline`: CI action versions are part of the repo tooling baseline; pinning to latest major versions is now a stated requirement

## Impact

- `.github/workflows/CI.yml`: rewritten jobs section
- `scripts/validate_bootstrap.sh`: may gain additional cases if coverage gaps are found during the audit
- No changes to `bootstrap.sh` or domain scripts
