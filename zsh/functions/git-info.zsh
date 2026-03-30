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

# Gets cached Git prompt information.
function git-info {
  setopt LOCAL_OPTIONS
  setopt EXTENDED_GLOB

  local added=0
  local added_format
  local added_formatted
  local branch
  local branch_format
  local branch_formatted
  local deleted=0
  local deleted_format
  local deleted_formatted
  local git_dir
  local -A info_formats
  local info_format
  local modified=0
  local modified_format
  local modified_formatted
  local renamed=0
  local renamed_format
  local renamed_formatted
  local action
  local action_format
  local action_formatted
  local stashed=0
  local stashed_format
  local stashed_formatted
  local status_cmd
  local untracked=0
  local untracked_format
  local untracked_formatted

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

  status_cmd="command git status --porcelain --ignore-submodules"
  while IFS=$'\n' read line; do
    [[ "$line" == ([ACDMT][\ MT]|[ACMT]D)\ * ]] && (( added++ ))
    [[ "$line" == [\ ACMRT]D\ * ]] && (( deleted++ ))
    [[ "$line" == ?[MT]\ * ]] && (( modified++ ))
    [[ "$line" == R?\ * ]] && (( renamed++ ))
    [[ "$line" == \?\?\ * ]] && (( untracked++ ))
  done < <(${(z)status_cmd} 2> /dev/null)

  if (( added > 0 )); then
    zstyle -s ':prezto:module:git:info:added' format 'added_format'
    zformat -f added_formatted "$added_format" "a:$added"
  fi

  if (( deleted > 0 )); then
    zstyle -s ':prezto:module:git:info:deleted' format 'deleted_format'
    zformat -f deleted_formatted "$deleted_format" "d:$deleted"
  fi

  if (( modified > 0 )); then
    zstyle -s ':prezto:module:git:info:modified' format 'modified_format'
    zformat -f modified_formatted "$modified_format" "m:$modified"
  fi

  if (( renamed > 0 )); then
    zstyle -s ':prezto:module:git:info:renamed' format 'renamed_format'
    zformat -f renamed_formatted "$renamed_format" "r:$renamed"
  fi

  if (( untracked > 0 )); then
    zstyle -s ':prezto:module:git:info:untracked' format 'untracked_format'
    zformat -f untracked_formatted "$untracked_format" "u:$untracked"
  fi

  if [[ -f "${git_dir}/refs/stash" ]]; then
    stashed="$(command git rev-list --walk-reflogs --count refs/stash 2> /dev/null)"
    if [[ -n "$stashed" && "$stashed" != 0 ]]; then
      zstyle -s ':prezto:module:git:info:stashed' format 'stashed_format'
      zformat -f stashed_formatted "$stashed_format" "S:$stashed"
    fi
  fi

  zstyle -a ':prezto:module:git:info:keys' format 'info_formats'
  for info_format in ${(k)info_formats}; do
    zformat -f REPLY "$info_formats[$info_format]" \
      "a:$added_formatted" \
      "b:$branch_formatted" \
      "d:$deleted_formatted" \
      "m:$modified_formatted" \
      "r:$renamed_formatted" \
      "s:$action_formatted" \
      "S:$stashed_formatted" \
      "u:$untracked_formatted"
    git_info[$info_format]="$REPLY"
  done

  unset REPLY

  return 0
}

# git-info "$@"
