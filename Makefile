all:
	zsh ./bootstrap.sh --all

test:
	zsh ./bootstrap.sh -v --ci

test_all:
	zsh ./bootstrap.sh -v --all --force --ci

test_dry_run:
	zsh ./bootstrap.sh -v --dry-run --all --force --ci
