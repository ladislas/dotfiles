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

	# Get Git repository information.
	# if (( $+functions[git-info] )); then
		git-info;
	# fi
}

# Load required functions.
autoload -Uz add-zsh-hook;

# Add hook for calling git-info before each command.
add-zsh-hook precmd prompt_precmd;
setopt prompt_subst

# Set editor-info parameters.
# zstyle ':prezto:module:editor:info:completing' format '${red}...%f%b';

# Set git-info parameters.
zstyle ':prezto:module:git:info' verbose 'yes';
zstyle ':prezto:module:git:info:branch' format '${turquoise}%b%f${git_info[rprompt]}';
zstyle ':prezto:module:git:info:added' format "${green}●%f";
zstyle ':prezto:module:git:info:modified' format "${yellow}●%f";
zstyle ':prezto:module:git:info:deleted' format "${red}●%f";
zstyle ':prezto:module:git:info:renamed' format "${orange}●%f";
zstyle ':prezto:module:git:info:stashed' format "${violet}●%f";
zstyle ':prezto:module:git:info:untracked' format "${white}●%f";
zstyle ':prezto:module:git:info:keys' format 'prompt' '(%b%S%a%d%m%r%U%u)'

# Define prompts.
PROMPT=$'\n${turquoise}#%f ${orange}%n%f @ ${yellow}%m%f in ${green}%~%f ${(e)git_info[prompt]}\n${green}→%f ';
# PROMPT=$'\n${turquoise}#%f ${orange}%n%f @ ${yellow}%m%f in ${green}%~%f \n${green}→%f ';
RPROMPT='';
SPROMPT='zsh: correct ${red}%R%f to ${green}%r%f [nyae]? ';
