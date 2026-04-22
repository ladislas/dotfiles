## ADDED Requirements

### Requirement: No broken aliases

Every alias in `git/config` SHALL expand to a syntactically valid Git command or shell expression. Aliases that are syntactically broken or silently expand incorrectly SHALL be removed.

#### Scenario: patch alias is absent

- **WHEN** a user runs `git patch`
- **THEN** Git SHALL report "patch" as an unknown command

#### Scenario: p alias is absent

- **WHEN** a user runs `git p`
- **THEN** Git SHALL report "p" as an unknown command

### Requirement: No aliases superseded by gh CLI or with unresolvable external dependencies

Aliases whose functionality is fully covered by `gh` CLI commands, or that depend on external binaries not managed by this dotfiles setup, SHALL be removed.

#### Scenario: mpr alias is absent

- **WHEN** a user runs `git mpr`
- **THEN** Git SHALL report "mpr" as an unknown command

#### Scenario: ack alias is absent

- **WHEN** a user runs `git ack`
- **THEN** Git SHALL report "ack" as an unknown command

### Requirement: reblc handles missing merge commit

The `reblc` alias SHALL exit with a clear error message when no merge commit exists in the current branch history, rather than passing an empty string to `git rebase -i`.

#### Scenario: reblc errors clearly on empty merge history

- **WHEN** a user runs `git reblc` on a branch with no merge commits in its history
- **THEN** the alias SHALL print `error: no merge commit found in history` and exit with a non-zero status without opening the rebase editor

#### Scenario: reblc prints the target commit before opening editor

- **WHEN** a user runs `git reblc` on a branch that has a merge commit in its history
- **THEN** the alias SHALL print a one-line summary of the merge commit it is rebasing from before opening the interactive rebase editor

### Requirement: Portable GPG path

The `[gpg]` program setting SHALL use a bare executable name (`gpg`) rather than an absolute path, so that PATH resolution applies on all architectures.

#### Scenario: GPG path is bare name

- **WHEN** `git/config` is read
- **THEN** the `gpg.program` value SHALL equal `gpg`

### Requirement: Branch-neutral comments

Comments in `git/config` SHALL NOT hardcode a specific default branch name (`master` or `main`). Where a branch name appears in a comment for illustrative purposes, it SHALL use neutral language (e.g., "default branch").

#### Scenario: dm alias comment is branch-neutral

- **WHEN** `git/config` is read
- **THEN** the comment above the `dm` alias SHALL reference "default branch", not `master` or `main`
