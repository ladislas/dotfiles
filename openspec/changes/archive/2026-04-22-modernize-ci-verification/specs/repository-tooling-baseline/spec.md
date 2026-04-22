## ADDED Requirements

### Requirement: CI action versions are pinned to current latest major releases

The CI workflow SHALL reference GitHub Actions at their current latest major version tag rather than old pinned releases or exact patch versions.

#### Scenario: Developer audits CI action versions

- **WHEN** a contributor reviews `.github/workflows/CI.yml`
- **THEN** all referenced actions use the latest published major version tag at the time of the last CI update

#### Scenario: CI workflow uses consistent action versions across all jobs

- **WHEN** multiple CI jobs reference the same action
- **THEN** all jobs reference the same major version of that action
