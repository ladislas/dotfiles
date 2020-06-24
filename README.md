# Home Sweet Home ![](https://github.com/ladislas/dotfiles/workflows/CI/badge.svg)

## About

This repository contains all my configs and simple scripts to setup a new Mac.

I try to keep `$HOME` as clean as possible by using [XDG Base Directory Specification](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html).

⚠️ Make sure you review the code before blindly using it.

## Install & Use

Clone the repo where you want, I usually do the following:

```console
$ mkdir -p ~/dev/ladislas
$ cd ~/dev/ladislas
$ git clone https://github.com/ladislas/dotfiles
$ cd dotfiles
```

Then run the bootstrap process:

```console
$ zsh bootstrap.sh [arguments]
```

Available arguments are:

- `--all` - run all scripts
- `--force` - used with `--all` skip the "Are you sure you want to continue" question
- `--test` - for CI
- `--verbose` or `-v` - print `stderr` message of failed commands
- `-vv` - print `stdout` & `stderr` messages

The rest is detailed here:

`--macos` `--brew` `--zsh` `--git` `--symlink` `--nvim` `--dev` `--data` `--gem-pip`

> https://github.com/ladislas/dotfiles/blob/master/bootstrap.sh#L123
