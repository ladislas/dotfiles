# Home Sweet Home ![](https://github.com/ladislas/dotfiles/workflows/CI/badge.svg)

## About

This repository contains all my configs and simple scripts to setup a new Mac.

I try to keep `$HOME` as clean as possible by using [XDG Base Directory Specification](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html).

⚠️ Make sure you review the code before blindly using it.

## Install & Use

Make sure you have Xcode installed first.

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
- `--ci` - for CI
- `--verbose` or `-v` - print `stderr` message of failed commands
- `-vv` - print `stdout` & `stderr` messages

The rest is detailed here:

`--hello` `--brew` `--apps-install` `--apps-config` `--zsh` `--git` `--symlink` `--nvim` `--dev` `--data` `--macos`

> https://github.com/ladislas/dotfiles/blob/master/bootstrap.sh

## Brew cask

I've removed some of the heavy casks from the script as they were taking way too much time...

To instatll them, run the following:

```bash
brew cask install mactex-no-gui
```

## Apps Settings

Apps must be launched first before syncronizing the settings. The script takes care of that but sometimes it might take a little longer or you might need to accept a dialog box.

For VSCode, use [Settings Sync](https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync).
