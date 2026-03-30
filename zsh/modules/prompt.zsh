#!/usr/bin/env zsh

#
# My prompt
#
# Authors:
#   Ladislas de Toldi <ladislas at detoldi dot me>
#

# Prompt colors
black="%F{0}";
darkgrey="%F{8}";
blue="%F{4}";
cyan="%F{6}";
green="%F{2}";
orange="%F{208}";
purple="%F{4}";
red="%F{1}";
violet="%F{13}";
white="%F{15}";
yellow="%F{3}";
turquoise="%F{81}";
purple2="%F{135}";
hotping="%F{161}";
limegreen="%F{118}";

# Load git-info & git-dir
. $ZFUNCTIONSDIR/git-dir.zsh
. $ZFUNCTIONSDIR/git-info.zsh

function prompt_precmd {
	setopt LOCAL_OPTIONS;
	unsetopt XTRACE KSH_ARRAYS;

	if [[ "${prompt_git_pwd-}" == "$PWD" && "${prompt_git_refresh-1}" == "0" ]]; then
		return 0;
	fi

	git-info;
	prompt_git_pwd="$PWD";
	prompt_git_refresh=0;
}

function prompt_preexec {
	prompt_git_refresh=1;
}

function prompt_chpwd {
	prompt_git_refresh=1;
}

# Load required functions.
autoload -Uz add-zsh-hook;

# Refresh prompt git state only when shell state changes.
add-zsh-hook precmd prompt_precmd;
add-zsh-hook preexec prompt_preexec;
add-zsh-hook chpwd prompt_chpwd;
setopt prompt_subst

# Set editor-info parameters.
# zstyle ':prezto:module:editor:info:completing' format '${red}...%f%b';

# Set git-info parameters.
zstyle ':prezto:module:git:info:branch' format '${turquoise}%b%f';
zstyle ':prezto:module:git:info:added' format '${green}●%f';
zstyle ':prezto:module:git:info:modified' format '${yellow}●%f';
zstyle ':prezto:module:git:info:deleted' format '${red}●%f';
zstyle ':prezto:module:git:info:renamed' format '${orange}●%f';
zstyle ':prezto:module:git:info:untracked' format '${white}●%f';
zstyle ':prezto:module:git:info:stashed' format '${violet}●%f';
zstyle ':prezto:module:git:info:action' format '${orange}%s%f';
zstyle ':prezto:module:git:info:keys' format 'prompt' '(%b%s%a%m%d%r%u%S)'

# Define prompts.
PROMPT=$'\n${turquoise}#%f ${orange}%n%f @ ${yellow}%m%f in ${green}%~%f ${(e)git_info[prompt]}\n%(?.${green}→.${red}→)%f ';
RPROMPT='%(?..${red}(%?%)%f)';
SPROMPT='zsh: correct ${red}%R%f to ${green}%r%f [nyae]? ';
