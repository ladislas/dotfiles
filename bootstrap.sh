#!/usr/bin/env zsh

trap 'exit 1' INT

typeset -x DOTFILES_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
typeset -gx TEMP_FILE="$(mktemp)"
typeset -ga FAILED_COMMANDS=()
typeset -ga CAN_FAIL_COMMANDS=()
typeset -ga ARG_ARRAY=()

typeset -gx DRY_RUN=false
typeset -gx FORCE=false
typeset -gx BOOTSTRAP_HOME="${BOOTSTRAP_HOME:-}"
typeset -gx COMPUTER_NAME=""
typeset -gx BREW_PREFIX=""

typeset -g VERBOSE_LEVEL=0
typeset -g RUN_ALL=false
typeset -g RUN_CI=false

typeset -ga QUALIFIER_FLAGS=("-v" "-vv" "--verbose" "--force")
typeset -ga MAIN_FLAGS=("--all" "--ci" "--dry-run")
typeset -ga DOMAIN_FLAGS=(
	"--hello"
	"--zsh"
	"--git"
	"--nvim"
	"--data"
	"--macos"
	"--brew"
	"--apps-install"
	"--apps-config"
	"--dev"
	"--rsync"
)
typeset -ga ALL_DOMAIN_FLAGS=(
	"--hello"
	"--zsh"
	"--git"
	"--nvim"
	"--data"
	"--macos"
	"--brew"
	"--apps-install"
	"--apps-config"
	"--dev"
	"--rsync"
)
typeset -ga CI_DOMAIN_FLAGS=(
	"--hello"
	"--git"
	"--nvim"
	"--data"
	"--dev"
)

trap 'rm -f "$TEMP_FILE"' EXIT HUP TERM

source "$DOTFILES_DIR/scripts/helpers/include.sh"

function try {
	. "$DOTFILES_DIR/scripts/helpers/try.sh" "$@"
}

alias try_can_fail='try -x'

function print_available_args {
	typeset -a available_args
	available_args=(
		"${QUALIFIER_FLAGS[@]}"
		"${MAIN_FLAGS[@]}"
		"${DOMAIN_FLAGS[@]}"
		"--computer_name=<value>"
	)
	printf '%s\n' "Please try again with one of those: ${available_args[*]}"
}

function fail_with_usage {
	printf '%s\n' "$1"
	print_available_args
	exit 1
}

function parse_args {
	if [ $# -eq 0 ]; then
		fail_with_usage "💥 No arguments have been passed."
	fi

	while [ $# -gt 0 ]; do
		case "$1" in
			-v|--verbose)
				VERBOSE_LEVEL=1
				;;
			-vv)
				VERBOSE_LEVEL=2
				;;
			--force)
				FORCE=true
				;;
			--dry-run)
				DRY_RUN=true
				;;
			--all)
				RUN_ALL=true
				;;
			--ci)
				RUN_CI=true
				;;
			--computer_name=*)
				COMPUTER_NAME="${1#--computer_name=}"
				if [ -z "$COMPUTER_NAME" ]; then
					fail_with_usage "💥 --computer_name requires a non-empty value."
				fi
				;;
			--hello|--zsh|--git|--nvim|--data|--macos|--brew|--apps-install|--apps-config|--dev|--rsync)
				ARG_ARRAY+=("$1")
				;;
			*)
				fail_with_usage "💥 Unrecognized argument: $1"
				;;
		esac
		shift
	done

	if [[ "$RUN_ALL" == true ]]; then
		if [[ "$FORCE" != true ]]; then
			echo ""
			echo "🔥 🔥 🔥"
			echo "You are about to run all the scripts. This is NOT recommended"
			echo "unless you know what you are doing! Unexpected behaviors can occur!"
			echo "🔥 🔥 🔥"
			echo ""
			echo "Please confirm that you have read the source files and are okay with that."
			printf '👀 Are you sure you want to continue? (y/n) '
			read
			if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
				echo ""
				echo "Goodbye, come again!..."
				exit 0
			fi
		fi

		echo ""
		echo "⚠️   Running bootstrap with all args! ⚠️"
		echo "	${ALL_DOMAIN_FLAGS[*]}"
		ARG_ARRAY=("${ALL_DOMAIN_FLAGS[@]}")
	fi

	if [[ "$RUN_CI" == true ]]; then
		echo ""
		echo "🔬 Running bootstrap for testing with the following args: 🧪"
		echo "	${CI_DOMAIN_FLAGS[*]}"
		ARG_ARRAY=("${CI_DOMAIN_FLAGS[@]}")
	fi

	if array_is_empty "${ARG_ARRAY[@]}"; then
		fail_with_usage "💥 No setup domains were selected."
	fi

	dedupe_array ARG_ARRAY

	if [[ "$VERBOSE_LEVEL" -ge 2 ]]; then
		alias try='try -vv'
	elif [[ "$VERBOSE_LEVEL" -ge 1 ]]; then
		alias try='try -v'
	fi
}

function configure_runtime_paths {
	if in_sandbox; then
		export HOME="$BOOTSTRAP_HOME"
		export XDG_CONFIG_HOME="$HOME/.config"
		export XDG_DATA_HOME="$HOME/.local/share"

		mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"

		echo ""
		echo "🧪 Running bootstrap with redirected home: $HOME"
	fi

	if is_dry_run; then
		echo ""
		echo "🏃 Running bootstrap as dry run. Nothing will be installed or modified... 🛡️"
	fi
}

function detect_brew_prefix {
	if command -v brew >/dev/null 2>&1; then
		BREW_PREFIX="$(brew --prefix)"
	elif test -d "/opt/homebrew/bin"; then
		BREW_PREFIX="/opt/homebrew"
	elif test -d "/usr/local/bin"; then
		BREW_PREFIX="/usr/local"
	else
		BREW_PREFIX=""
	fi
}

function add_brew_paths {
	if [ -z "$BREW_PREFIX" ]; then
		return 0
	fi

	print_action "Add brew to path"
	fake_try "export PATH=\"$BREW_PREFIX/bin:\$PATH\""
	export PATH="$BREW_PREFIX/bin:$PATH"

	if [ -d "$BREW_PREFIX/opt/coreutils/libexec/gnubin" ]; then
		print_action "Add gnubin to path"
		fake_try "export PATH=\"$BREW_PREFIX/opt/coreutils/libexec/gnubin:\$PATH\""
		export PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
	fi
}

function selection_requires_brew_bootstrap {
	for arg in "${ARG_ARRAY[@]}"; do
		case "$arg" in
			--brew|--apps-install|--apps-config|--zsh)
				return 0
				;;
		esac
	done

	return 1
}

function install_prerequisites {
	if is_dry_run; then
		detect_brew_prefix
		add_brew_paths
		return 0
	fi

	if ! selection_requires_brew_bootstrap; then
		detect_brew_prefix
		add_brew_paths
		return 0
	fi

	print_section "Checking for brew & coreutils"

	if ! command -v brew >/dev/null 2>&1; then
		print_action "Install brew"
		fake_try '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		if [ $? -ne 0 ]; then
			echo "💥 Could not install Homebrew."
			exit 1
		fi
	fi

	detect_brew_prefix
	add_brew_paths

	if ! command -v gls >/dev/null 2>&1; then
		print_action "Install coreutils"
		fake_try 'brew install coreutils'
		brew install coreutils
		if [ $? -ne 0 ]; then
			echo "💥 Could not install coreutils."
			exit 1
		fi
		add_brew_paths
	fi
}

function validate_execution_plan {
	if args_contain '--macos' && [ -z "$COMPUTER_NAME" ]; then
		echo "💥 --macos requires a computer name to be set with --computer_name=YOUR_NAME"
		exit 1
	fi

	if ! in_sandbox; then
		return 0
	fi

	typeset -a sandbox_unsupported=()
	for arg in "${ARG_ARRAY[@]}"; do
		case "$arg" in
			--zsh|--brew|--apps-install|--apps-config|--macos|--rsync)
				sandbox_unsupported+=("$arg")
				;;
		esac
	done

	if ! array_is_empty "${sandbox_unsupported[@]}"; then
		echo "💥 Sandbox mode only supports user-scoped setup domains. Unsupported args: ${sandbox_unsupported[*]}"
		exit 1
	fi
}

function ensure_sudo_if_needed {
	if ! args_contain '--macos' && ! args_contain '--brew'; then
		return 0
	fi

	if ! sudo -n true 2>/dev/null; then
		echo ""
		echo "🔐 Args --macos & --brew require sudo to run. 🔐"
		ask_for_sudo
	fi
}

function run_bootstrap {
	if args_contain '--hello'; then
		print_section 'Starting Hello, World! script'
		print_action "Make sure we're good to go"
		try echo 'Hello, World!'
		try echo "Let's get moving!"
		try_can_fail false
	fi

	if args_contain '--brew'; then
		print_section 'Starting brew configuration script'
		source "$DOTFILES_DIR/scripts/brew.sh"
	fi

	if args_contain '--apps-install'; then
		print_section 'Starting applications installation script'
		source "$DOTFILES_DIR/scripts/apps.sh"
	fi

	if args_contain '--apps-config'; then
		print_section 'Starting applications configuration script'
		source "$DOTFILES_DIR/scripts/apps_config.sh"
	fi

	if args_contain '--zsh'; then
		print_section 'Starting zsh configuration script'

		ask_for_sudo

		if [ -n "$BREW_PREFIX" ] && ! fgrep -q "${BREW_PREFIX}/bin/zsh" /etc/shells; then
			print_action 'Setting brew zsh as default shell'
			try echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells
			try chsh -s "${BREW_PREFIX}/bin/zsh"
		fi

		print_action 'Clean up zcompdump'
		try rm -f ~/.zcompdump
		try rm -f "$DOTFILES_DIR/zsh/.zcompdump"
		try rm -f "$DOTFILES_DIR/zsh/.zcompdump.zwc"

		if [ -n "$BREW_PREFIX" ]; then
			print_action "chmod $BREW_PREFIX/share for completion"
			try chmod -R go-w "$BREW_PREFIX/share"
		fi

		print_action 'Symlink config files'
		try mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
		try ln -sr "$DOTFILES_DIR/symlink/.zshenv" "$HOME/.zshenv"
		try ln -sr "$DOTFILES_DIR/zsh" "${XDG_CONFIG_HOME:-$HOME/.config}/"
	fi

	if args_contain '--git'; then
		print_section 'Starting git configuration script'
		print_action 'Symlink config files'
		try mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
		try ln -sr "$DOTFILES_DIR/git" "${XDG_CONFIG_HOME:-$HOME/.config}/"
	fi

	if args_contain '--nvim'; then
		print_section 'Starting neovim configuration script'
		print_action 'Git clone neovim config'
		try git clone --recursive https://github.com/ladislas/nvim "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
	fi

	if args_contain '--data'; then
		print_section 'Starting XDG Data configuration script'
		print_action 'Symlink config files'
		try mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}"
		try ln -sr "$DOTFILES_DIR"/data/* "${XDG_DATA_HOME:-$HOME/.local/share}"
	fi

	if args_contain '--dev'; then
		print_section 'Starting personnal dev configuration script'
		source "$DOTFILES_DIR/scripts/dev.sh"
	fi

	if args_contain '--macos'; then
		print_section 'Starting macOS configuration script'
		source "$DOTFILES_DIR/scripts/macos.sh"
	fi

	if args_contain '--rsync'; then
		print_section 'Starting rsync configuration script'
		source "$DOTFILES_DIR/scripts/rsync_config.sh"
	fi
}

parse_args "$@"
configure_runtime_paths
validate_execution_plan
install_prerequisites
ensure_sudo_if_needed
run_bootstrap
list_failed_commands
