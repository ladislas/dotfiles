# Project Guidelines

## Git Commits

This repo uses [gitmoji](https://gitmoji.dev). Commit format:

```text
<emoji> (<topic>): <message>
```

Example: `🔧 (tooling): Add mise and hk workflow`

Use the `gitmoji` CLI to find the right emoji: `gitmoji list`

## Git Workflow

### Branch Naming

Branches follow the pattern: `<firstname>/<type>/<topic-more_info>`

- Types: `feature`, `release`, `bugfix`
- Example: `ladislas/feature/setup-mise-hk-linters`

Always create a branch — keep `main` clean.

## OpenSpec

- Use OpenSpec in this repo for meaningful multi-step work, not for tiny obvious edits.
- Keep change artifacts under `openspec/` until the work is complete and ready to archive.
- Commit meaningful OpenSpec artifacts when they preserve rationale and review context.
- Keep the human in the loop: proposal, design, specs, and tasks should guide implementation rather than replace review and judgment.

## Local Tooling

- Trust and install repo-local tools with `mise trust && mise install`
- Run repo checks with `mise run lint`
- Install hooks with `mise run hooks`
- Use `mise run lint:fix` before committing if Markdown lint wants autofixes
