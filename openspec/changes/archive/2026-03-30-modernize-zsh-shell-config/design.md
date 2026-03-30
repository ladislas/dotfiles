## Context

The current zsh config already has a clean high-level structure: shared functions live under `zsh/functions/`, interactive modules live under `zsh/modules/`, and the repo avoids a plugin manager in favor of explicit sourcing. The problems are inside those boundaries rather than in the overall structure.

`.zshenv` currently does more than environment setup. It sources helper functions and runs command-based logic such as `which nvim` and `tty` for `GPG_TTY`, which affects non-interactive shells. `.zshrc` mixes interactive module loading with machine-specific paths and stale shell customizations, including a broken `git reabse -i` alias and hard-coded paths for a Python user bin directory and a local Google Cloud SDK install. Prompt rendering is also heavier than necessary: `zsh/modules/prompt.zsh` invokes `git-info` on every `precmd`, and `zsh/functions/git-info.zsh` runs multiple git commands and porcelain parsing on prompt redraw.

This change should modernize those boundaries without changing the repo's operating model. The modular layout stays. Interactive ergonomics stay. The change is specifically about making the shared zsh config safer, faster, and more portable.

## Goals / Non-Goals

**Goals:**

- Restore a clean startup boundary between always-loaded environment config and interactive shell behavior.
- Reduce prompt git overhead enough that prompt redraw cost stays predictable in larger repositories.
- Make shared shell config portable by removing or isolating machine-specific paths and stale assumptions.
- Keep the modular zsh structure and explicit sourcing model easy to follow.
- Make verification explicit so startup and prompt behavior can be checked after each implementation phase.

**Non-Goals:**

- Introduce a plugin manager or replace the current module/function layout.
- Redesign the shell prompt visually beyond changes required by the new git-info behavior.
- Rewrite the entire alias/function set or modernize unrelated shell tooling in one pass.
- Build a full cross-shell abstraction layer for bash, fish, or other shells.

## Decisions

### 1. Keep `.zshenv` limited to non-interactive-safe environment setup

`.zshenv` should only contain exports and shell configuration that is safe for every zsh invocation. Helper sourcing, editor detection via external commands, `tty`-derived `GPG_TTY`, and other interactive or command-dependent logic should move into the interactive startup path or into modules that are loaded only when appropriate.

This preserves expected zsh startup semantics and avoids non-interactive shells paying for logic they do not need.

**Alternatives considered:**

- Keep current behavior and accept the extra work in all shells: rejected because issue #41 specifically calls out startup boundary problems.
- Push all logic into `.zprofile` or `.zlogin`: rejected because the main distinction needed here is interactive versus always-loaded behavior, not login-shell-only behavior.

### 2. Favor prompt speed and simplicity over exact expensive git status on every redraw

The prompt should stop computing detailed repository accounting on each `precmd`. The design priority is fast, bounded prompt updates that preserve basic git awareness without parsing full porcelain status and stash state every redraw.

The target behavior is:

- keep branch visibility in the prompt
- keep a coarse repository-state signal when it is cheap enough to compute
- avoid exact per-category counts and other expensive status detail on every redraw
- prefer simple git plumbing or cached state over multiple porcelain-heavy subprocesses

This is the main design choice for the change: exact prompt status is less important than prompt responsiveness and implementation simplicity.

**Alternatives considered:**

- Keep the current detailed `git-info` behavior: rejected because it is the performance problem.
- Add a complex async prompt framework: rejected because it changes the repo's explicit lightweight configuration model.

### 3. Make interactive load order explicit in `.zshrc`

`.zshrc` should clearly separate path setup, completion initialization, module loading, and late-loaded interactive enhancements. Syntax-highlighting load order should be reviewed so it is loaded where it is expected, instead of ahead of other interactive modules in a way that is easy to misread.

The goal is not to chase a perfect framework-like lifecycle. It is to make the existing explicit sourcing order obvious and maintainable.

**Alternatives considered:**

- Leave the current load order and only comment it: rejected because the issue is partly about making the order itself easier to reason about.

### 4. Isolate portability concerns from shared shell defaults

Machine-specific paths and local SDK hooks should not be hard-coded into shared zsh config unless they are portable, configurable, or intentionally local-only. This change should either remove stale entries, move them behind machine-local opt-in hooks, or replace them with more general patterns that fit the repo's XDG-ish layout and explicit config style.

Broken aliases, GNU-only assumptions, and vendored completion drift should be reviewed in the same pass because they are the same class of shell-config debt: local assumptions that leaked into shared defaults.

**Alternatives considered:**

- Keep machine-specific entries documented as personal preferences: rejected because the issue explicitly asks for machine-specific shell config cleanup.

## Risks / Trade-offs

- **Less detailed prompt status** -> Mitigation: keep branch visibility and a coarse git state signal so the prompt remains useful even if it is no longer exact.
- **Moving startup logic can change long-standing behavior** -> Mitigation: verify interactive and non-interactive zsh startup separately after each phase.
- **Portability cleanup may remove something still used on one machine** -> Mitigation: prefer opt-in local hooks or documented local overrides instead of silently dropping legitimate machine-specific setup.
- **Load-order changes can affect completion or highlighting behavior** -> Mitigation: include explicit startup smoke checks and completion/highlighting validation in the implementation tasks.

## Migration Plan

1. Clean up startup boundaries first so `.zshenv` becomes safe for non-interactive use.
2. Simplify prompt git behavior second, with prompt speed favored over exact detailed status.
3. Clean up portability and stale interactive config third, including load order and machine-specific paths.
4. Finish with explicit shell smoke tests and repo lint tasks.

Rollback is straightforward: revert the change if the new startup or prompt behavior regresses interactive use.

## Open Questions

- Should the simplified prompt show only branch plus a single dirty indicator, or also keep one or two cheap extra signals such as staged changes if they can be derived without expensive porcelain parsing?
- What is the preferred repository pattern for machine-local shell extensions: an ignored local file, an XDG-local override, or a narrow environment-variable-based opt-in?
