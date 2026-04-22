### Requirement: CI runs the bootstrap validation script as the authoritative contract check

CI SHALL execute `scripts/validate_bootstrap.sh` as a dedicated job that verifies bootstrap contract behaviors without requiring manual invocation or a fully provisioned machine.

#### Scenario: CI passes when all bootstrap contract checks succeed

- **WHEN** the validation script runs in CI and all assertions pass
- **THEN** the `validate-bootstrap` job exits successfully

#### Scenario: CI fails when a bootstrap contract check fails

- **WHEN** the validation script runs in CI and any assertion fails
- **THEN** the `validate-bootstrap` job exits non-zero with the failing check identified in the output

### Requirement: CI bootstrap validation uses the same tooling baseline as local development

The CI bootstrap validation job SHALL set up repo-local tooling via `mise` before running the validation script, ensuring the runner environment matches local development.

#### Scenario: Validation job installs repo tooling before running checks

- **WHEN** the `validate-bootstrap` CI job starts
- **THEN** it installs the repo-local mise toolchain before invoking `scripts/validate_bootstrap.sh`

### Requirement: CI documents its bootstrap verification scope

The CI configuration SHALL make explicit which bootstrap behaviors are verified in automation and which are excluded because they require a provisioned machine or user interaction.

#### Scenario: Excluded domains are not exercised in CI

- **WHEN** CI runs bootstrap verification
- **THEN** it does not attempt to run Homebrew installs, macOS system preference changes, app configuration sync, or rsync operations
