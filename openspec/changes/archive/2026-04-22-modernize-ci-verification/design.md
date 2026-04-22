## Context

The repository CI has two distinct concerns that are currently tangled:

1. **Content linting** — already modernized: uses `actions/checkout@v4` and `jdx/mise-action@v2`, runs `mise run lint`.
2. **Bootstrap verification** — four jobs using `actions/checkout@v2.0.0` that run ad-hoc bootstrap invocations reflecting historical script shape rather than documented guarantees.

`scripts/validate_bootstrap.sh` was introduced as part of the bootstrap foundation refactor and already encodes the bootstrap contract: symlink idempotency, conflict backup, two-run convergence, sandbox blocking, argument rejection, and recoverable failure reporting. The CI workflow does not yet use it.

## Goals / Non-Goals

**Goals:**

- Replace four stale bootstrap CI jobs with a single job that runs `scripts/validate_bootstrap.sh`
- Update all GitHub Action versions to their current latest major release (`actions/checkout@v6`, `jdx/mise-action@v4`)
- Make the CI contract explicit: what is verified, and what is excluded

**Non-Goals:**

- Adding new bootstrap behaviors or modifying `bootstrap.sh`
- Testing machine-specific operations (Homebrew installs, macOS system prefs, app syncing) in CI
- Expanding CI into a multi-matrix or cross-platform setup

## Decisions

### Decision: Single validation job replaces four ad-hoc jobs

**Chosen:** One `validate-bootstrap` job that runs `scripts/validate_bootstrap.sh`.

**Alternatives considered:**

- Keep and update the four existing jobs — rejected. They exercise the CLI surface with no assertions about outcomes. `validate_bootstrap.sh` already captures the contract with actual assertions; duplicating it in workflow YAML adds noise without coverage benefit.
- Write inline validation steps in YAML — rejected. The script is already tested locally and keeps CI and local validation in sync automatically.

### Decision: Pin to latest major version tags, not full patch versions

**Chosen:** `actions/checkout@v6`, `jdx/mise-action@v4` (major version tags).

**Alternatives considered:**

- Pin exact patch versions (e.g., `v6.0.2`) — over-specified for a personal dotfiles repo; major version tags receive compatible patches from action authors and reduce maintenance churn.
- Leave versions as-is — rejected. `v2.0.0` is pinned to an exact old release; it receives no security or compatibility fixes.

### Decision: Add mise setup to the bootstrap validation job

**Chosen:** Add `jdx/mise-action@v4` before running `validate_bootstrap.sh`.

**Rationale:** The validation script invokes `bootstrap.sh` which sources domain scripts. Ensuring the runner has the same mise-provided tooling as local development avoids environment drift between CI and local runs.

## Risks / Trade-offs

- **Major version bump on checkout could introduce breaking changes** → Mitigation: CI will catch it immediately on the first push; `actions/checkout@v6` is the current stable release.
- **validate_bootstrap.sh covers fewer CLI flag combinations than the old four jobs** → Acceptable trade-off. The old jobs had no assertions; the script tests behavioral contracts, not CLI surface breadth.
- **validate_bootstrap.sh missing coverage gaps discovered later** → The script lives in the repo and can be extended alongside `bootstrap.sh` changes; CI will reflect those updates automatically.

## Migration Plan

1. Update `actions/checkout` and `jdx/mise-action` versions in the lint job
2. Replace the four bootstrap jobs with a single `validate-bootstrap` job using the updated action versions and running `scripts/validate_bootstrap.sh`
3. Push and verify CI passes
4. Close issue #45

No rollback complexity — this is a workflow file change only.
