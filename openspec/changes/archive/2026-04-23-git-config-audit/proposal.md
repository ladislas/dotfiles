## Why

`git/config` contains several aliases that are either visibly broken (will error on invocation), have been superseded by the `gh` CLI, or carry an external binary dependency. In addition, the GPG program is hardcoded to an Intel-only Homebrew path, and one comment hardcodes a branch name in a way that is misleading for repos using a different default branch. These are concrete maintenance problems — not philosophical concerns about alias style.

## What Changes

- Remove `p` — `p = git pull --recurse-submodules` is not a shell alias, so Git expands it as `git git pull …` which fails
- Remove `patch` — the alias body (`--no-colormessage(STATUS "")`) is syntactically invalid
- Remove `mpr` — local PR merge workflow superseded by `gh pr checkout` (`prc`) and `gh pr merge`
- Remove `ack` — depends on the external `ack` binary; `rg` / `git grep` cover the same need
- Improve `reblc` — keep the alias, add error handling for when no merge commit exists in history, and print the commit being rebased from so it is not silent
- Replace hardcoded `/usr/local/bin/gpg` with `gpg` to rely on PATH (Intel vs. Apple Silicon portability)
- Update the `dm` alias comment to say "default branch" instead of `master`
- Keep `mmnoff`, `mnoff`, and all discovery/log/search aliases intact

## Capabilities

### New Capabilities

- `git-config-safe-aliases`: Git alias set with no broken entries, no obsolete aliases, a portable GPG path, branch-neutral comments, and hardened interactive-rebase helper

### Modified Capabilities

<!-- No existing spec-level capabilities are changing -->

## Impact

- `git/config` — only file modified
- Any notes referencing `git mpr`, `git p`, `git patch`, or `git ack` will be stale (none identified in this repo)
- GPG path change is purely portability; no behavioral change on machines where `gpg` is on PATH
- `reblc` behavior is unchanged for the normal case; new behavior is an error message and non-zero exit when no merge commit is found
