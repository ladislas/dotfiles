## Context

`bootstrap.sh` is the repository's machine setup entrypoint and currently combines argument parsing, prerequisite installation, privilege escalation, command execution, symlink creation, and per-domain orchestration in one implicit runtime. The current implementation relies on regex checks against a flattened argument array, parses `--computer_name=...` with `ggrep`, records failures through a wrapper that obscures command attribution, and uses non-idempotent symlink operations that fail on rerun.

This change needs to improve correctness without changing the basic operating model. The repository should keep a single bootstrap entrypoint and targeted setup flags, but the runtime must become explicit enough to validate before mutating the machine and predictable enough to rerun after partial success. It also needs a safe way to exercise user-scoped behavior against a redirected target root so bootstrap verification does not depend on risking the operator's real environment.

## Goals / Non-Goals

**Goals:**

- Make bootstrap flag parsing explicit, deterministic, and independent of Homebrew-provided tools.
- Validate incompatible or incomplete flag combinations before stateful work begins.
- Define clear execution semantics for fatal failures, recoverable failures, dry-run behavior, and end-of-run reporting.
- Make bootstrap-managed symlink operations converge on rerun instead of failing on existing targets.
- Support redirected user-scoped target paths for safe bootstrap verification and repeated local test runs.
- Document the runtime contract shared between `bootstrap.sh` and sourced domain scripts.

**Non-Goals:**

- Rewriting bootstrap in another language.
- Replacing the single-entrypoint shell workflow with a new framework or subcommand architecture.
- Changing unrelated macOS, zsh, git, or application setup behavior beyond what is required for correctness and rerun safety.
- Fully sandboxing system-scoped operations such as `sudo`, `/etc/shells`, `chsh`, Homebrew installation, or macOS defaults writes.
- Solving every legacy bootstrap concern in one pass.

## Decisions

### 1. Keep the implementation in shell and refactor toward boring, mostly POSIX-style structure

The problem is brittle logic, not an inherent need for Ruby or a larger rewrite. Keeping shell avoids introducing a second bootstrap dependency while allowing a small diff that preserves the existing repo workflow. The implementation may remain `zsh`-executed for compatibility with the current repo, but parsing and helper logic should avoid zsh-specific cleverness.

**Alternatives considered:**

- Rewrite in Ruby: clearer data structures and parsing, but it adds migration cost and ties bootstrap reliability to an old system Ruby runtime.
- Full bash migration: attractive long term, but broader churn than needed for the first correctness pass.

### 2. Parse arguments with an explicit loop and derive runtime state before execution

Bootstrap should consume arguments in order using a normal `case` loop, record selected domains, qualifiers, and parameterized values, then validate the final state before running any setup domain. Special flags such as `--all`, `--ci`, `--dry-run`, and `--computer_name=...` should be expanded or recorded through normal control flow rather than regex matching.

This makes invalid combinations fail early and lets the script compute whether sudo, Homebrew bootstrap, or machine-specific inputs are required before modifying the system.

**Alternatives considered:**

- Preserve regex-based checks against a shared argument array: smaller edit in the short term, but still opaque and error-prone.
- Use `zparseopts`: workable, but unnecessary complexity for the small supported option set.

### 3. Separate fatal and recoverable command execution semantics

Bootstrap should define two clear command paths:

- **fatal** operations stop execution immediately because later work would be unsafe or misleading
- **recoverable** operations are recorded and summarized without aborting the entire run

The command helper should preserve visible attribution of the failing command, support dry-run logging, and avoid output capture that hides what actually ran. Domain scripts should choose the appropriate helper based on whether failure invalidates the current runtime.

**Alternatives considered:**

- Continue the current "try everything and summarize later" approach: acceptable for demos, not for stateful setup.
- Abort on every failure: simpler, but too rigid for optional or best-effort steps.

### 4. Standardize rerun-safe file linking through a shared helper

Bootstrap-managed links should use a replace-safe helper that ensures the destination points at the intended source after each run. Existing desired links should be treated as success, stale files should be replaced safely, and parent directories should be created as needed. Domain scripts should stop calling raw `ln -sr` directly for managed links.

**Alternatives considered:**

- Patch each `ln` call independently: low upfront effort but guarantees inconsistency.
- Leave current behavior and document rerun caveats: not acceptable for a bootstrap foundation.

### 5. Document a minimal runtime contract for sourced domain scripts

The bootstrap runtime should explicitly document what scripts may assume, including key environment variables, logging helpers, command helpers, dry-run semantics, and when sudo has already been acquired. This keeps the current source-based orchestration model while reducing hidden dependencies on mutable globals.

**Alternatives considered:**

- Convert every domain script into an executable subcommand: cleaner boundaries, but outside the scope of the minimal refactor.

### 6. Support redirected user-scoped targets through explicit runtime overrides

Bootstrap should support an explicit sandbox mode for user-scoped operations by allowing the runtime to override `HOME` and derived XDG paths, either through a dedicated environment variable such as `BOOTSTRAP_HOME` or through a narrow set of explicit path overrides. This allows validation of symlink creation, directory setup, clone destinations, and rerun behavior against a temporary target tree instead of the real user environment.

The bootstrap runtime should treat system-scoped operations separately: in sandboxed runs, domains that require sudo, write outside the redirected user tree, or mutate system settings should be skipped or rejected clearly unless explicitly enabled. That keeps the first testing model practical instead of pretending to offer full isolation.

**Alternatives considered:**

- Rely on dry-run alone: safer than a real run, but it cannot prove idempotency or resulting filesystem state.
- Test directly against the real home directory: unacceptable risk for a refactor whose purpose is to improve safety.
- Build full VM or container isolation first: powerful, but too heavy for the initial validation loop.

## Risks / Trade-offs

- **Behavior changes in flag handling** → Mitigation: preserve existing public flags and validate them with dry-run scenarios before changing execution defaults.
- **Refactoring shared helpers can break multiple domains at once** → Mitigation: centralize the runtime contract and verify at least one representative flow for each affected helper pattern.
- **More explicit fatal failures may stop flows that previously limped along** → Mitigation: define fatality intentionally and document the distinction in the change artifacts.
- **Shell portability can regress if zsh-only constructs remain hidden in helpers** → Mitigation: keep parsing and helper logic deliberately simple and avoid shell-specific tricks unless required.
- **Sandbox support can create a false sense of total isolation** → Mitigation: document that redirected-home validation covers user-scoped behavior only and explicitly reject or skip system-scoped mutations in sandbox mode.

## Migration Plan

1. Introduce the runtime contract and explicit argument parsing structure.
2. Replace brittle helper behavior with transparent fatal/recoverable execution helpers.
3. Update bootstrap-managed symlink operations to use the shared rerun-safe helper.
4. Add redirected-home validation for user-scoped bootstrap flows and use it to verify dry-run, invalid-input, and rerun scenarios.
5. Land the refactor without changing the user-facing bootstrap entrypoint.

Rollback is straightforward: revert the change set and restore the prior bootstrap behavior if the new runtime breaks setup flows.

## Open Questions

- Which existing operations should remain recoverable instead of fatal after the refactor?
- Should the redirected-home test entrypoint be exposed as a dedicated bootstrap flag, an environment variable, or only a repository-owned validation script?
- Is there any remaining setup domain that truly requires zsh-specific behavior, or can helpers be written to stay bash-compatible over time?
