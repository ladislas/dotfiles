all:
	zsh ./bootstrap.sh --all

test:
	zsh ./bootstrap.sh --test

test_all:
	zsh ./bootstrap.sh -v --all --force