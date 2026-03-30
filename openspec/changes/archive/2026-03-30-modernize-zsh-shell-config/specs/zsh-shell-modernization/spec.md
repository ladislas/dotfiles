## ADDED Requirements

### Requirement: Zsh startup files respect interactive boundaries

The zsh configuration SHALL keep `.zshenv` limited to non-interactive-safe environment setup and SHALL move command-driven or helper-sourcing behavior into interactive startup paths when that behavior is not safe for all zsh invocations.

#### Scenario: Non-interactive zsh does not load interactive helper logic

- **WHEN** a non-interactive zsh process starts
- **THEN** `.zshenv` does not source interactive helper functions or run command-based editor detection

#### Scenario: Interactive-only terminal state is not set in `.zshenv`

- **WHEN** zsh starts in a context without a usable terminal
- **THEN** the shared startup path does not rely on `tty`-derived state such as `GPG_TTY` from `.zshenv`

### Requirement: Prompt git information prioritizes low-latency redraws

The shell prompt SHALL expose useful git context while preferring simple, low-latency status signals over exact expensive repository accounting on every prompt redraw.

#### Scenario: Prompt redraw avoids full porcelain parsing for detailed counts

- **WHEN** the prompt redraws inside a git worktree
- **THEN** prompt git rendering avoids detailed per-category repository counting through repeated expensive git status parsing on each `precmd`

#### Scenario: Prompt still shows basic git context

- **WHEN** the current directory is inside a git worktree
- **THEN** the prompt still exposes at least branch context and a basic repository-state signal consistent with the simplified design

### Requirement: Interactive module load order is explicit and maintainable

The interactive zsh startup SHALL make module and enhancement load order clear enough that completion, autosuggestions, history search, prompt behavior, and syntax highlighting can be reasoned about from `.zshrc` without hidden ordering assumptions.

#### Scenario: Syntax highlighting loads in an intentional late interactive position

- **WHEN** `.zshrc` loads interactive modules
- **THEN** the placement of `zsh-syntax-highlighting` is explicit and consistent with the intended ordering of other interactive modules

### Requirement: Shared zsh config avoids machine-specific hard-coded paths and stale shell debt

The shared zsh configuration SHALL not require machine-specific absolute paths, stale aliases, or unreviewed GNU-only assumptions to provide its default interactive behavior.

#### Scenario: Shared config does not embed local SDK or user-specific absolute paths

- **WHEN** the zsh config is used on another machine
- **THEN** shared startup files do not depend on hard-coded local paths such as a user Desktop SDK install or a version-pinned user Python bin directory

#### Scenario: Shared aliases and completions remain valid after cleanup

- **WHEN** the interactive shell loads the modernized shared config
- **THEN** broken aliases and stale vendored completion assumptions have been corrected, removed, or isolated from the default shared path
