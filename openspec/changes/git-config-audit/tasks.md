## 1. Remove broken aliases

- [x] 1.1 Remove the `patch` alias (malformed body)
- [x] 1.2 Remove the `p` alias (non-shell pull alias that expands incorrectly)

## 2. Remove superseded and stale aliases

- [x] 2.1 Remove the `mpr` alias (superseded by `gh pr checkout` / `gh pr merge`)
- [x] 2.2 Remove the `ack` alias (external `ack` binary dependency)

## 3. Improve reblc

- [x] 3.1 Add a guard that exits with `error: no merge commit found in history` when `git log --merges -n 1` returns empty
- [x] 3.2 Add a status line that prints the selected merge commit (`git log --oneline -n 1`) before opening the rebase editor
- [x] 3.3 Clean up the stray tab character in the alias body

## 4. Portability fixes

- [x] 4.1 Change `gpg.program` from `/usr/local/bin/gpg` to `gpg`
- [x] 4.2 Update the `dm` alias comment — replace "merged with master" with "merged with the default branch"
