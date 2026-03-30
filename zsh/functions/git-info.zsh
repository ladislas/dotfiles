#!/usr/bin/env zsh

#
# Exposes Git repository information via the $git_info associative array.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Gets the Git special action (merge, rebase, cherry-pick, revert, bisect).
function _git-info-action {
  local git_dir="$1"

  if [[ -d "${git_dir}/rebase-merge" || -d "${git_dir}/rebase-apply" || -d "${git_dir}/rebase" ]]; then
    print 'REBASE'
    return 0
  fi

  if [[ -f "${git_dir}/MERGE_HEAD" ]]; then
    print 'MERGE'
    return 0
  fi

  if [[ -f "${git_dir}/CHERRY_PICK_HEAD" ]]; then
    print 'PICK'
    return 0
  fi

  if [[ -f "${git_dir}/REVERT_HEAD" ]]; then
    print 'REVERT'
    return 0
  fi

  if [[ -f "${git_dir}/BISECT_LOG" ]]; then
    print 'BISECT'
    return 0
  fi

  return 1
}

# Gets low-cost Git prompt information.
function git-info {
  setopt LOCAL_OPTIONS

  local branch
  local branch_format
  local branch_formatted
  local dirty=0
  local git_dir
  local -A info_formats
  local info_format
  local action
  local action_format
  local action_formatted
  local state_format
  local state_formatted

  unset git_info
  typeset -gA git_info

  if ! is-true "$(command git rev-parse --is-inside-work-tree 2> /dev/null)"; then
    return 1
  fi

  if (( $# > 0 )); then
    if [[ "$1" == [Oo][Nn] ]]; then
      command git config --bool prompt.showinfo true
    elif [[ "$1" == [Oo][Ff][Ff] ]]; then
      command git config --bool prompt.showinfo false
    else
      print "usage: $0 [ on | off ]" >&2
    fi
    return 0
  fi

  git_dir="$(git-dir 2> /dev/null)" || return 1
  branch="$(command git symbolic-ref --quiet --short HEAD 2> /dev/null)"
  if [[ -z "$branch" ]]; then
    branch="$(command git rev-parse --short HEAD 2> /dev/null)"
  fi

  zstyle -s ':prezto:module:git:info:branch' format 'branch_format'
  if [[ -n "$branch" && -n "$branch_format" ]]; then
    zformat -f branch_formatted "$branch_format" "b:$branch"
  fi

  action="$(_git-info-action "$git_dir")"
  zstyle -s ':prezto:module:git:info:action' format 'action_format'
  if [[ -n "$action" && -n "$action_format" ]]; then
    zformat -f action_formatted "$action_format" "s:$action"
  fi

  command git diff --no-ext-diff --quiet --ignore-submodules --cached 2> /dev/null || dirty=1
  if (( ! dirty )); then
    command git diff --no-ext-diff --quiet --ignore-submodules 2> /dev/null || dirty=1
  fi

  zstyle -s ':prezto:module:git:info:state' format 'state_format'
  if (( dirty )) && [[ -n "$state_format" ]]; then
    zformat -f state_formatted "$state_format" "d:dirty"
  fi

  zstyle -a ':prezto:module:git:info:keys' format 'info_formats'
  for info_format in ${(k)info_formats}; do
    zformat -f REPLY "$info_formats[$info_format]" \
      "b:$branch_formatted" \
      "d:$state_formatted" \
      "s:$action_formatted"
    git_info[$info_format]="$REPLY"
  done

  unset REPLY

  return 0
}

# git-info "$@"
