## Context

The repository already installs `mise` through Homebrew during bootstrap, but it does not define any repo-local tools, lint tasks, or git hooks. It also lacks the OpenSpec/opencode project structure used in the shared `mypac` setup, which means upcoming issue work would need to recreate the same scaffolding piecemeal.

OpenSpec-generated Markdown and command/skill overlays are slightly different from normal prose files, so the lint configuration needs layered overrides instead of a single blanket rule set. The baseline should stay small: enough to validate Markdown and YAML, wire hooks, and provide the expected opencode/OpenSpec layout without dragging in every possible linter on day one.

## Goals / Non-Goals

**Goals:**
- Define a repo-local tooling baseline that contributors can install and run with `mise`.
- Enforce Markdown and YAML checks through both explicit tasks and pre-commit hooks.
- Create the OpenSpec and opencode scaffolding needed for future spec-driven changes in this repository.
- Keep the initial lint surface narrow so adoption does not require a broad shell-script cleanup.

**Non-Goals:**
- Add every possible linter for the repository, especially shell-focused tools that may require broad remediation.
- Refactor the bootstrap scripts beyond what is necessary to document or expose the new workflow.
- Replace existing Homebrew-based installation of `mise`.

## Decisions

### Use repo-local `mise` config and tasks

The repository already depends on Homebrew for machine bootstrap, so `mise` should remain installed there. Repo-local `mise` config will instead define the exact developer tools and common task entry points. This keeps setup reproducible without coupling day-to-day commands to the bootstrap scripts.

Alternative considered: add direct package-manager scripts only. Rejected because hooks and lint tasks would then depend on ad hoc local installations instead of a pinned toolchain.

### Use `hk` for pre-commit enforcement

`hk` gives a small, declarative hook configuration and already matches the pattern used in `mypac`. Pairing it with a `mise run hooks` task keeps hook installation explicit and reproducible.

Alternative considered: keep hooks manual or use a different hook runner. Rejected because that would duplicate the problem this change is meant to solve.

### Layer Markdown lint configuration by directory

A root `.markdownlint.yaml` will hold shared defaults, while `openspec/` and `.opencode/` get local overrides for generated and command-style Markdown. This mirrors the working setup in `mypac` and avoids forcing awkward prose conventions on generated artifacts.

Alternative considered: a single global config. Rejected because OpenSpec artifacts and opencode command files have formatting patterns that would trigger noisy false positives.

### Initialize opencode as a project-local overlay

OpenSpec can scaffold opencode assets, but the repository should also carry the project-local overlay files that make the workflow understandable and lintable, including `.opencode/AGENTS.md`, `.opencode/.markdownlint.yaml`, and ignore rules for local package-manager artifacts.

Alternative considered: rely only on generated files. Rejected because the generated scaffold alone does not document repository preferences or lint exceptions clearly.

## Risks / Trade-offs

- [Generated OpenSpec opencode scaffolding may not match current repo conventions] → Normalize the overlay structure and document the intended layout in project guidance.
- [New hooks may block commits for existing Markdown or YAML issues] → Keep the initial lint scope focused and add a `mise run lint:fix` entry point for Markdown autofixes.
- [CI may drift from local tooling if it keeps calling old commands] → Add a CI job that installs the `mise` toolchain and runs the repo-local lint tasks.
