# Project Preferences

## Tooling

This project uses [opencode](https://opencode.ai) as the AI coding assistant.
Do NOT suggest or create configurations for vendor-specific CLIs unless the user explicitly asks for them.

- Project-local overlay assets belong in `.opencode/`
- OpenSpec artifacts live under `openspec/`
- Keep repo-local tooling in `.mise/` and `.config/`

## OpenSpec Workflow

- Use OpenSpec in this repo for meaningful multi-step work, not for tiny obvious edits.
- Keep change artifacts under `openspec/changes/` until implementation is complete and ready to archive.
- Commit meaningful OpenSpec artifacts when they preserve rationale and review context.
- Keep the human in the loop: proposal, design, specs, and tasks should guide implementation rather than replace judgment.
