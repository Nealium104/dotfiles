# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# add a directory to PATH only if it isn't there already, so nested shells
# (tmux panes, subshells) don't keep growing it
path_prepend() { case ":$PATH:" in *":$1:"*) ;; *) PATH="$1:$PATH" ;; esac; }
path_append() { case ":$PATH:" in *":$1:"*) ;; *) PATH="$PATH:$1" ;; esac; }

path_prepend "$HOME/.local/bin"
path_append /usr/local/go/bin
path_append "$HOME/go/bin"
export PATH

# ansible hard-fails if this points at a missing file, so only set it on
# machines that actually have the script
if [ -f "$HOME/bin/vaultpw.sh" ]; then
  export ANSIBLE_VAULT_PASSWORD_FILE="$HOME/bin/vaultpw.sh"
fi

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=50000
HISTFILESIZE=100000

# share history between open shells (tmux panes): write each command out as
# it's run and pick up what other shells have written
case "${PROMPT_COMMAND:-}" in
  *'history -a'*) ;;
  *) PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# sourcing nvm.sh costs ~400ms per shell, so put the default node on PATH
# directly and only load nvm itself the first time it's called
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  _nvm_default=$(cat "$NVM_DIR/alias/default" 2>/dev/null)
  case "$_nvm_default" in
    [0-9]*|v[0-9]*) _nvm_default="v${_nvm_default#v}" ;;
    *) _nvm_default=v ;; # node, stable, lts/*, or unset: newest installed
  esac
  _nvm_node=$(printf '%s\n' "$NVM_DIR"/versions/node/"$_nvm_default"* | sort -V | tail -n1)
  [ -d "$_nvm_node/bin" ] && path_prepend "$_nvm_node/bin"
  unset _nvm_default _nvm_node

  nvm() {
    unset -f nvm
    . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    nvm "$@"
  }
fi

# fzf: ctrl-r history, ctrl-t files, alt-c directories. fd keeps .gitignore'd
# files out of the list and bat previews the highlighted file
if command -v fzf >/dev/null; then
  if command -v fd >/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  fi
  if command -v bat >/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
  fi
  if fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"
  elif [ -s /usr/share/doc/fzf/examples/key-bindings.bash ]; then
    . /usr/share/doc/fzf/examples/key-bindings.bash # apt's older fzf
  fi
fi

command -v starship >/dev/null && eval "$(starship init bash)"

# Make neovim the default editor
export EDITOR=nvim

# Config for WezTerm
export WEZTERM_CONFIG_FILE=~/.config/wezterm/wezterm.lua

# once per terminal, not in every tmux pane
[ -z "$TMUX" ] && command -v fastfetch >/dev/null && fastfetch
command -v wslview >/dev/null && export BROWSER=wslview

export ANSIBLE_SSH_ARGS='-o ControlMaster=auto -o ControlPersist=60s -o ServerAliveInterval=5'

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

command -v zoxide >/dev/null && eval "$(zoxide init bash)"
