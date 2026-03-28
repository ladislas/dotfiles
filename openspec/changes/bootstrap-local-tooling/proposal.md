## Why

This repository is about to grow a set of GitHub issue-driven changes, but it does not yet have a consistent local tooling baseline for linting, hooks, and OpenSpec-assisted workflow support. Setting that foundation now avoids noisy follow-up diffs, inconsistent Markdown validation, and one-off setup steps while implementing the real work.

## What Changes

- Add a repo-local tooling baseline driven by mise tasks and hk git hooks.
- Add Markdown and YAML lint configuration that works for both repository docs and generated OpenSpec artifacts.
- Initialize OpenSpec and opencode project scaffolding so future changes can use the same directory layout and agent guidance as the shared setup in `~/ladislas/dev/ladislas/mypac`.
- Update repository documentation and CI entry points so contributors can discover and run the new checks predictably.

## Capabilities

### New Capabilities
- `repository-tooling-baseline`: Define the required local tooling, lint configuration, hook integration, and OpenSpec/opencode scaffolding for this repository.

### Modified Capabilities

None.

## Impact

- Adds repo-local configuration under `.mise/`, `.config/`, `.opencode/`, and `openspec/`.
- Introduces new developer dependencies managed by mise: `hk`, `pkl`, `markdownlint-cli2`, and `yamllint`.
- Updates contributor-facing docs and CI so lint and hook setup are visible and repeatable.
