## ADDED Requirements

### Requirement: Repository defines a pinned local tooling baseline
The repository SHALL define a repo-local `mise` configuration for developer tooling required by its documentation and OpenSpec workflow.

#### Scenario: Developer installs repository tools
- **WHEN** a contributor runs `mise install` in the repository root
- **THEN** the repository installs the pinned tooling needed by local lint and hook tasks

### Requirement: Repository exposes lint tasks for tracked Markdown and YAML files
The repository SHALL provide `mise` tasks that lint tracked Markdown and YAML files through consistent repository-owned entry points.

#### Scenario: Developer runs the default lint task
- **WHEN** a contributor runs `mise run lint`
- **THEN** the repository runs both Markdown and YAML lint tasks against tracked files

#### Scenario: Developer fixes Markdown lint errors
- **WHEN** a contributor runs `mise run lint:fix`
- **THEN** the repository applies autofixable Markdown changes to tracked Markdown files

### Requirement: Repository enforces content checks through git hooks
The repository SHALL define a pre-commit hook configuration that runs Markdown and YAML checks together with basic repository hygiene checks.

#### Scenario: Developer installs hooks
- **WHEN** a contributor runs the repository hook installation task
- **THEN** git hooks are installed through `hk` with `mise` integration

#### Scenario: Developer commits Markdown or YAML changes
- **WHEN** a commit includes tracked Markdown or YAML files
- **THEN** the pre-commit hook runs the configured content checks before the commit completes

### Requirement: Repository supports OpenSpec and opencode content linting
The repository SHALL include OpenSpec and opencode directory scaffolding together with Markdown lint overrides that allow generated and workflow-specific Markdown files to lint correctly.

#### Scenario: Developer creates OpenSpec change artifacts
- **WHEN** the repository contains proposal, design, task, or spec files under `openspec/`
- **THEN** Markdown lint uses the OpenSpec-specific overrides for those files

#### Scenario: Developer uses opencode overlay assets
- **WHEN** the repository contains Markdown command or guidance files under `.opencode/`
- **THEN** Markdown lint uses the opencode-specific overrides for those files

### Requirement: Repository documents and validates the tooling workflow
The repository SHALL document the new tooling entry points and expose them to CI so the local workflow is reproducible in automation.

#### Scenario: Contributor reads setup documentation
- **WHEN** a contributor reviews the repository documentation
- **THEN** they can discover how to install the toolchain, install hooks, and run lint checks

#### Scenario: CI validates repository content
- **WHEN** CI runs for the repository
- **THEN** it installs the repo-local toolchain and runs the repository-owned lint entry points
