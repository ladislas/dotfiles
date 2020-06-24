all:
	zsh ./bootstrap.sh --all

test_quick:
	zsh ./bootstrap.sh -v --hello --zsh --git --symlink --nvim --data --macos

test:
	zsh ./bootstrap.sh -v --ci

test_dry_run:
	zsh ./bootstrap.sh -v --dry-run --all --force --ci
