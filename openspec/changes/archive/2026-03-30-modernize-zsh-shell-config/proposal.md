## Why

Issue #41 identified a set of zsh configuration problems that all come from the same source: startup boundaries are blurry, prompt git state is more expensive than it needs to be, and machine-specific shell setup has accumulated directly into shared config. The result is slower prompt redraws, non-interactive shell side effects, and lower portability across machines.

## What Changes

- Move non-interactive-safe environment setup into the correct startup boundary and stop loading helper functions or command-based editor/GPG detection from `.zshenv`.
- Simplify prompt git state so prompt redraw favors speed and predictable latency over exact expensive repository status accounting.
- Revisit interactive module load order in `.zshrc`, especially syntax-highlighting placement, so the order is explicit and easier to reason about.
- Remove or isolate machine-specific paths, stale aliases, GNU-specific assumptions, and vendored completion drift that should not live in the shared zsh config.
- Preserve the current modular zsh structure, XDG-ish layout, explicit config approach, and interactive ergonomics around completion, history, editor mode, aliases, and git awareness.

## Capabilities

### New Capabilities

- `zsh-shell-modernization`: Defines the startup, prompt, and portability expectations for the repository's modular zsh configuration.

### Modified Capabilities

- None.

## Impact

- Affected code: `zsh/.zshenv`, `zsh/.zshrc`, `zsh/modules/*.zsh`, and `zsh/functions/*.zsh` used by prompt and interactive startup.
- Affected behavior: interactive shell startup, non-interactive shell safety, prompt redraw cost, and machine portability of shared shell config.
- Verification: shell startup smoke checks plus repository lint tasks, including Markdown lint for these OpenSpec artifacts and the smallest relevant repo lint task for the eventual config changes.
