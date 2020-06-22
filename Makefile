all:
	zsh ./bootstrap.sh --all

test:
	zsh ./bootstrap.sh --ci

test_all:
	zsh ./bootstrap.sh -v --all --force --ci
