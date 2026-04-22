## Context

`git/config` is a dotfiles configuration loaded on every machine. It contains ~30 aliases covering daily-use shortcuts, rich log helpers, and advanced merge/rebase workflow aliases (`mmnoff`, `mnoff`, `reblc`) that are core personal tooling for a gitflow-inspired feature-branch workflow. These are not candidates for removal.

The actionable problems are: two aliases that fail on invocation (`p`, `patch`), two aliases that are obsolete or have external dependencies (`mpr`, `ack`), one alias that works but silently fails in edge cases and gives no feedback (`reblc`), a GPG program path hardcoded to Intel Homebrew, and one comment that hardcodes `master`.

## Goals / Non-Goals

**Goals:**

- Remove aliases that are visibly broken and will error on invocation
- Remove aliases superseded by `gh` CLI or with unmaintained external dependencies
- Harden `reblc` with an error message when no merge commit exists and a status line showing which commit it rebases from
- Fix the GPG path to rely on PATH instead of a hardcoded Homebrew x86 path
- Update the `dm` comment to say "default branch" (neutral across repos using `main`, `master`, or anything else)
- Preserve `mmnoff`, `mnoff`, `reblc`, and all discovery/log/search aliases

**Non-Goals:**

- Removing or redesigning `mmnoff` / `mnoff` / `reblc` — these are core daily-use workflow aliases
- Adding new aliases or restructuring the alias block
- Modifying any file other than `git/config`
- Changing core Git settings (`pull.ff`, `fetch.prune`, signing defaults, etc.)

## Decisions

### Remove `p` (pull with submodules)

`p = git pull --recurse-submodules` is not prefixed with `!`, so Git expands it as `git git pull --recurse-submodules`, which fails. The fix would be `!git pull --recurse-submodules`, but submodule usage is uncommon in this workflow and `pull.ff = only` already covers the common pull path. Remove rather than fix.

### Remove `patch`

The alias body (`--no-colormessage(STATUS "")`) is syntactically invalid. It was never functional. Remove.

### Remove `mpr`

`mpr` fetches a PR ref, rebases it, merges it locally, and amends the commit message. This is fully covered by `gh pr checkout` (already aliased as `prc`) and `gh pr merge`. Remove.

### Remove `ack`

`ack = ! git ls-files | ack -x` requires the external `ack` binary. `rg` and `git grep` are already available and more portable. Remove.

### Improve `reblc` (keep, harden)

The current implementation is a bare one-liner with no error handling:

```gitconfig
reblc = "!r() { git rebase -i $(git log --pretty=format:"%H" --merges -n 1 ); }; r"
```

Problems:

- If no merge commit exists in history, `git log` returns empty and `git rebase -i` receives no argument, producing a cryptic error
- No output before opening the editor — the user has no idea which commit was selected
- Stray tab character in the body

Improved version:

```gitconfig
reblc = "!r() { \
    MERGE=$(git log --format='%H' --merges -n 1); \
    if [ -z \"$MERGE\" ]; then \
        echo 'error: no merge commit found in history'; \
        exit 1; \
    fi; \
    echo \"rebasing from: $(git log --oneline -n 1 $MERGE)\"; \
    git rebase -i \"$MERGE\"; \
}; r"
```

Behavior is identical for the normal case. The only new behaviors are a clear error on empty history and a one-line status before the editor opens.

### Fix GPG path

Change `program = /usr/local/bin/gpg` to `program = gpg`. The hardcoded path is only valid for Homebrew on Intel Macs; on Apple Silicon it is `/opt/homebrew/bin/gpg`. Using the bare binary name defers to PATH, which `mise` and Homebrew manage correctly on both architectures.

### Update `dm` comment

The comment above `dm` says "merged with master". Because this config is used across repos with different default branch names, rephrase to "merged with the default branch" — accurate regardless of whether a repo uses `main`, `master`, or something else.

## Risks / Trade-offs

- **`reblc` improvement**: The alias body changes but behavior is identical when a merge commit exists. The error path is new; it replaces a cryptic Git error with a clear message. No regression risk.
- **GPG path change may fail if `gpg` is not on PATH** → PATH management is the right layer to fix this; not a regression introduced here.
- **`mpr` removal** → No documentation referencing `git mpr` has been identified in this repo.
