#!/usr/bin/env zsh

#
# Main zshrc configuration file
#
# Authors:
#   Ladislas de Toldi <ladislas at detoldi dot me>
#

# ⚠️ Uncomment to profile
# zmodload zsh/zprof

#
# macOS setup
#

if [[ "$OSTYPE" == darwin* ]]; then

	eval "$($BREW_PREFIX/bin/brew shellenv)"

	typeset -U lpath=() # set local path

	# brew bin/sbin
	lpath+="$BREW_PREFIX/bin $BREW_PREFIX/sbin"

	# Use GNU Coreutils instead of Apple's
	if which gwhoami >/dev/null 2>&1; then
		lpath+="$BREW_PREFIX/opt/coreutils/libexec/gnubin"
		eval $( gdircolors -b "$ZDOTDIR/lscolors/dircolors.ladislas" )
		# Alias ls to use color output
		alias ls="${aliases[ls]:-ls} --group-directories-first --color=auto"
	fi

	# GNU Tar
	lpath+="$BREW_PREFIX/opt/gnu-tar/libexec/gnubin"

	# GNU Find
	lpath+="$BREW_PREFIX/opt/findutils/libexec/gnubin"

	# Ruby
	lpath+="$BREW_PREFIX/opt/ruby/bin"
	lpath+="$BREW_PREFIX/lib/ruby/gems/3.2.0/bin"

	# Python
	# lpath+="/Users/ladislas/Library/Python/3.9/bin/"

	# Export $PATH
	path=($lpath $path)

fi

#
# Modules options
#

# Set the key layout (vi or emacs)
zstyle ':module:editor' key-bindings 'vi'

#
# Modules
#

if [ -f $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] ; then
	source $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

. $ZMODULESDIR/editor.zsh
. $ZMODULESDIR/completion.zsh
. $ZMODULESDIR/directory.zsh
. $ZMODULESDIR/history.zsh
. $ZMODULESDIR/autosuggestions.zsh
. $ZMODULESDIR/history-substring-search.zsh
. $ZMODULESDIR/prompt.zsh

#
# Completions, zcompdump & compinit
#

# Do not check .zcompdump each time
# autoload -Uz compinit
# if [ $(date +'%j') != $(/usr/bin/stat -f '%Sm' -t '%j' $ZDOTDIR/.zcompdump) ]; then
# 	compinit $ZDOTDIR/.zcompdump
# else
# 	compinit -C
# fi

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit -d $ZDOTDIR/.zcompdump
else
	compinit -C
fi

# If zcompdump becomes a burden, check this out
# https://github.com/ladislas/prezto/blob/master/runcoms/zlogin
# Execute code that does not affect the current session in the background.
{
	# Compile the completion dump to increase startup speed.
	zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
	if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
		zcompile "$zcompdump"
	fi
} &!

#
# Aliases
#

# ls, the common ones I use a lot shortened for rapid fire usage
alias l='ls -lFh'     #size,show type,human readable
alias la='ls -lAFh'   #long list,show almost all,show type,human readable
alias lr='ls -tRFh'   #sorted by date,recursive,show type,human readable
alias lt='ls -ltFh'   #long list,sorted by date,show type,human readable
alias ll='ls -l'      #long list
alias ldot='ls -ld .*'
alias lS='ls -1FSsh'
alias lart='ls -1Fcart'
alias lrt='ls -1Fcrt'
function lls {
	LLS_PATH=$1
	\ls -lAFh $LLS_PATH | awk "{k=0;for(i=0;i<=8;i++)k+=((substr(\$1,i+2,1)~/[rwx]/) \
		*2^(8-i));if(k)printf(\"%0o \",k);print}"
}

# System info, history and help
alias dud='du -d 1 -h'
alias duf='du -sh *'
alias fd='find . -type d -name'
alias ff='find . -type f -name'

alias h='history'
alias hgrep="fc -El 0 | grep"
alias help='man'
alias p='ps -f'
alias sortnr='sort -n -r'
alias unexport='unset'

# Git
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gd='git diff'
alias gco='git checkout'
alias gst='git status'
alias gmnoff='git merge --no-ff'
alias gri='git reabse -i'
alias grdev='git rebase develop'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Git flow
alias gf='git-flow'
alias gffs='git-flow feature start'
alias gfff='git-flow feature finish'

# Gem
alias gi='gem install --no-document'
alias gu='gem update --no-document'
alias gem-update='gu'

# Python
function pip_update_all_user {
	if [[ $(python3 -m pip list --user --outdated) ]]; then
		echo "pip will update the --user installed packages..."
		python3 -m pip list --user --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 python3 -m pip install --user -U
	else
		echo "pip did not find any --user installed packages to update."
	fi
}

alias pipinstall='python3 -m pip install --user'
alias pipupdate='python3 -m pip install -U'
alias pipupdate=pip_update_all_user

# Miscs
alias qq='exit'

# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias launchservices_cleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# chmod
alias getchmod="stat --format '%a'"
alias makeexec="chmod +x"
alias unexec="chmod -x"

function deep-profile {
	zmodload zsh/zprof
	source $ZDOTDIR/.zshrc
	zprof
	source $ZDOTDIR/.zshrc
}

# Not sure if need for the moment
# autoload -U colors && colors
# autoload -Uz promptinit
# promptinit

#
# Plugins - late installs
#

# ️⚠️ Uncomment to profile
# might need that later https://github.com/benvan/sandboxd
# zprof
