# Home Sweet Home !["Github Actions Status Badge](https://github.com/ladislas/dotfiles/workflows/CI/badge.svg)

## About

This repository contains all my configs and simple scripts to setup a new Mac.

I try to keep `$HOME` as clean as possible by using [XDG Base Directory Specification](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html).

⚠️ Make sure you review the code before blindly using it.

## Install & Use

Make sure you have Xcode and/or the Command Line Tools are installed first:

```console
xcode-select --install
```

Install [Homebrew](https://brew.sh/):

```console
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Clone the repo where you want, I usually do the following:

```console
mkdir -p ~/dev/ladislas
cd ~/dev/ladislas
git clone https://github.com/ladislas/dotfiles
cd dotfiles
```

or run the following (only if you are me):

```console
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ladislas/dotfiles/main/install.sh)"
```

Then run the bootstrap process:

```console
zsh bootstrap.sh [arguments]
```

To validate user-scoped bootstrap behavior safely against a temporary home target:

```console
BOOTSTRAP_HOME=/tmp/dotfiles-bootstrap-test zsh bootstrap.sh --git --data --dev
# conflicting real targets are preserved in sibling .bootstrap-backup/ directories
```

## Local Tooling

This repository also defines repo-local tooling for docs and workflow validation.

```console
mise trust
mise install
mise run hooks
mise run lint
mise run bootstrap:validate
```

- `mise trust` marks the repo-local mise configuration as trusted on your machine
- `mise install` installs the pinned local tools used by this repo
- `mise run hooks` installs git hooks through `hk`
- `mise run lint` runs the Markdown and YAML checks used locally and in CI
- `mise run lint:fix` applies autofixable Markdown changes
- `mise run bootstrap:validate` exercises bootstrap in a redirected-home sandbox without touching your real home directory

OpenSpec artifacts live under `openspec/`, and opencode project-local overlays live under `.opencode/`.

Available arguments are:

- `--all` - run all scripts
- `--force` - used with `--all` skip the "Are you sure you want to continue" question
- `--ci` - for CI
- `--verbose` or `-v` - print `stderr` message of failed commands
- `-vv` - print `stdout` & `stderr` messages

The rest is detailed here:

`--hello` `--zsh` `--git` `--nvim` `--data` `--macos --computer_name=xxx` `--brew` `--apps-install` `--apps-config` `--dev`

> <https://github.com/ladislas/dotfiles/blob/main/bootstrap.sh>

### Recommended Order

```bash
# check if things work
zsh bootstrap.sh --hello

# then zsh + git
zsh bootstrap.sh --zsh --git

# start with brew + apps
zsh bootstrap.sh --brew --apps-install

# finally macos
zsh bootstrap.sh --macos --computer_name=xxx

# the rest is only needed if you are me
zsh bootstrap.sh --apps-config --dev --data --nvim
```

## Brew casks/formulae

I've removed some of the heavy casks & formulae from the script as they were taking way too much time...

To instatll them, run the following:

```bash
# swiftlint needs xcode installed
brew install swiftlint

# mandatory for signing commits
brew install --no-quarantine gpg-suite-no-mail

# Formulae
brew install imagemagick

# Casks
brew install --no-quarantine adoptopenjdk
brew install --no-quarantine mactex-no-gui
```

## Apps Settings

Apps must be launched first before syncronizing the settings. The script takes care of that but sometimes it might take a little longer or you might need to accept a dialog box.

## Desktop State Workflow

The desktop setup now has an explicit source-of-truth workflow:

1. Make desktop preference and Dock changes on the main machine.
2. Run `zsh bootstrap.sh --rsync` on the main machine to export the managed desktop roots back into the repo.
3. Review and commit the resulting `Library/**` updates plus `config/dock.tsv`.
4. Run `zsh bootstrap.sh --apps-config` on another machine to apply the managed desktop state and Dock manifest.
5. Run `zsh bootstrap.sh --macos --computer_name=<name>` to apply the explicit macOS defaults and stable machine name.

### Source-of-Truth Rules

- The main machine is the source of truth for managed desktop state.
- `Library/**` tracked desktop files and directories are exported from the main machine with `--rsync`, then applied elsewhere with `--apps-config`.
- `config/dock.tsv` is the canonical Dock manifest. Do not treat `com.apple.dock.plist` as a tracked source of truth.
- `com.apple.symbolichotkeys.plist` remains part of the managed desktop export/apply flow.
- Brave Browser and iTerm Dock entries are conditional and are only applied when those apps are installed.
