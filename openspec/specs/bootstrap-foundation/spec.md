## ADDED Requirements

### Requirement: Bootstrap parses supported arguments explicitly

The bootstrap entrypoint SHALL parse supported flags and parameterized values through explicit control flow without depending on Homebrew-installed utilities or regex matching against flattened argument arrays.

#### Scenario: Parameterized computer name is parsed without external grep utilities

- **WHEN** a user runs bootstrap with `--computer_name=<value>`
- **THEN** bootstrap records the provided computer name without requiring `ggrep`, `grep -P`, or other non-default parsing tools

#### Scenario: Unsupported flag is rejected deterministically

- **WHEN** a user passes an argument that is not in the supported bootstrap flag set
- **THEN** bootstrap exits with an error before executing any setup domain

### Requirement: Bootstrap validates execution prerequisites before mutating system state

The bootstrap entrypoint SHALL validate required flag combinations and runtime prerequisites before executing stateful setup operations.

#### Scenario: macOS setup requires an explicit computer name

- **WHEN** a user selects `--macos` without providing `--computer_name=<value>`
- **THEN** bootstrap exits with a clear validation error before starting macOS setup or any later stateful step that depends on that input

#### Scenario: Aggregate flags expand into a validated execution plan

- **WHEN** a user selects an aggregate mode such as `--all` or `--ci`
- **THEN** bootstrap expands that mode into the corresponding domain set and validates any additional required inputs before running those domains

### Requirement: Bootstrap distinguishes fatal and recoverable failures

The bootstrap runtime SHALL provide explicit execution semantics for fatal operations that stop the run and recoverable operations that are summarized at the end.

#### Scenario: Fatal failure stops bootstrap execution

- **WHEN** a command marked as fatal fails during bootstrap execution
- **THEN** bootstrap stops further domain execution and exits non-zero with the failing command clearly identified

#### Scenario: Recoverable failure is reported without aborting the full run

- **WHEN** a command marked as recoverable fails during bootstrap execution
- **THEN** bootstrap records the failure, continues allowed work, and includes the failure in the final summary

### Requirement: Bootstrap-managed links are rerun-safe

Bootstrap-managed symlink operations SHALL converge on the desired target state when bootstrap is rerun after partial setup or existing configuration drift.

#### Scenario: Existing desired symlink is treated as success

- **WHEN** bootstrap reruns and a managed destination already points to the intended source
- **THEN** the link step succeeds without reporting a failure

#### Scenario: Existing conflicting destination is replaced safely

- **WHEN** bootstrap manages a destination path that already exists but does not point to the intended source
- **THEN** bootstrap replaces or updates that destination so the final state matches the managed source

### Requirement: Bootstrap supports redirected user-scoped targets for safe validation

The bootstrap runtime SHALL support redirected user-scoped target paths so user-environment changes can be validated without mutating the operator's real home directory.

#### Scenario: User-scoped paths resolve under a redirected bootstrap home

- **WHEN** bootstrap runs with an explicit redirected home target for validation
- **THEN** user-scoped operations resolve `HOME` and derived XDG paths under that redirected target instead of the operator's real home directory

#### Scenario: Redirected-home runs remain rerun-safe

- **WHEN** bootstrap is executed repeatedly against the same redirected home target
- **THEN** user-scoped bootstrap operations converge on the desired state without introducing new failures on rerun

### Requirement: Sandbox validation does not silently perform system-scoped mutations

The bootstrap runtime SHALL reject or skip system-scoped operations during redirected-home validation unless those operations are explicitly enabled.

#### Scenario: System-scoped domain is blocked during sandbox validation

- **WHEN** a redirected-home validation run selects a domain that writes outside user-scoped paths or requires privileged system mutation
- **THEN** bootstrap reports that the domain is unsupported in sandbox mode and does not perform the system-scoped action

### Requirement: Domain scripts rely on a documented bootstrap runtime contract

The bootstrap system SHALL define the runtime inputs and helper behaviors that sourced domain scripts may rely on.

#### Scenario: Domain script uses documented runtime helpers

- **WHEN** a setup domain script is sourced by bootstrap
- **THEN** the script can rely on the documented environment variables, logging helpers, command helpers, and dry-run semantics provided by bootstrap

#### Scenario: Bootstrap documents privilege expectations for domain scripts

- **WHEN** a setup domain requires elevated privileges
- **THEN** the bootstrap runtime specifies whether the script must request sudo itself or may assume sudo has already been acquired before execution
