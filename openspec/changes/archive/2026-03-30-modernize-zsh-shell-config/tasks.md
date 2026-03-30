## 1. Startup boundary cleanup

- [x] 1.1 Refactor `zsh/.zshenv` so it contains only non-interactive-safe environment setup, moving helper sourcing and command-based logic out of the always-loaded startup path
- [x] 1.2 Re-home editor detection, terminal-derived `GPG_TTY`, and any other interactive-only shell behavior into the appropriate interactive module or startup file while preserving the current modular structure
- [x] 1.3 Keep the existing exported path and environment behavior intact where it is still portable and appropriate for all zsh invocations
- [x] 1.4 Verify startup boundaries with explicit smoke checks: `zsh -fc 'exit 0'`, `zsh -ic 'exit 0'`, and a targeted check that non-interactive startup does not require terminal-only state

## 2. Prompt performance cleanup

- [x] 2.1 Redesign prompt git state so prompt redraw favors branch visibility and simple low-cost repository signals over exact detailed status accounting
- [x] 2.2 Update `zsh/modules/prompt.zsh` and any supporting functions so prompt redraw no longer performs the current expensive git-info work on every `precmd`
- [x] 2.3 Simplify or replace `zsh/functions/git-info.zsh` behavior as needed to align with the new low-latency prompt design while preserving useful git awareness
- [x] 2.4 Verify prompt behavior with explicit checks in and out of a git worktree, including repeated prompt redraw smoke tests and startup profiling evidence if needed to confirm the prompt path no longer does expensive status work per redraw

## 3. Portability and stale shell config cleanup

- [x] 3.1 Review `.zshrc` interactive load order and make module sequencing, completion setup, and syntax-highlighting placement explicit and maintainable
- [x] 3.2 Remove, isolate, or replace machine-specific path entries such as the local Python user bin path and Desktop Google Cloud SDK hooks so shared config stays portable
- [x] 3.3 Fix stale shell debt in the shared config, including the broken `git reabse -i` alias and any GNU-only assumptions or vendored completion paths that should not remain in the default shared path
- [x] 3.4 Verify interactive ergonomics after the cleanup with explicit checks for shell startup, completion initialization, syntax highlighting load, and representative aliases still behaving as expected

## 4. Verification and documentation

- [x] 4.1 Run `mise run lint:markdown` to validate the OpenSpec artifact updates and any Markdown touched during the change
- [x] 4.2 Run `mise run lint` as the smallest relevant repo-wide validation task for the zsh config changes
- [x] 4.3 Update any contributor-facing shell documentation only if the implementation changes a supported local override pattern or expected zsh workflow behavior
- [x] 4.4 Confirm the final change matches issue #41 scope only: startup modernization, prompt performance, and machine-specific shell config cleanup
