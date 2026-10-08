# add a directory to PATH only if it isn't there already, so nested shells
# (tmux panes, subshells) don't keep growing it
path_prepend() { case ":$PATH:" in *":$1:"*) ;; *) PATH="$1:$PATH" ;; esac; }
path_append() { case ":$PATH:" in *":$1:"*) ;; *) PATH="$PATH:$1" ;; esac; }

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.cargo/bin" # before the aliases start
path_prepend "$HOME/.local/share/fnm/aliases/default/bin" # the default node
path_append /usr/local/go/bin
path_append "$HOME/go/bin"
export PATH

# ansible hard-fails if this points at a missing file
# only set on machines that actually have the script
if [ -f "$HOME/bin/vaultpw.sh" ]; then
  export ANSIBLE_VAULT_PASSWORD_FILE="$HOME/bin/vaultpw.sh"
fi

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

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

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# colours for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# programmable completion, unless /etc/bash.bashrc already loaded it
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# fnm switches node version on cd into a project with an .nvmrc or
# .node-version; the default node is already on PATH from the top of this file
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell bash)"

# fzf: ctrl-r history, ctrl-t files, alt-c directories. fd keeps .gitignore'd
# files out of the list and bat previews the highlighted file
if command -v fzf >/dev/null; then
  if command -v fd >/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  fi
  # catppuccin macchiato, without a background so the terminal's shows through
  export FZF_DEFAULT_OPTS="\
--color=bg+:#363a4f,spinner:#f4dbd6,hl:#ed8796 \
--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
--color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 \
--color=selected-bg:#494d64,border:#6e738d,label:#cad3f5"
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

export EDITOR=nvim

# Config for WezTerm
export WEZTERM_CONFIG_FILE=~/.config/wezterm/wezterm.lua

# once per terminal, not in every tmux pane
[ -z "$TMUX" ] && command -v fastfetch >/dev/null && fastfetch
command -v wsl-open >/dev/null && export BROWSER=wsl-open

export ANSIBLE_SSH_ARGS='-o ControlMaster=auto -o ControlPersist=60s -o ServerAliveInterval=5'

# webi puts the tools it installs on PATH through envman
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

command -v zoxide >/dev/null && eval "$(zoxide init bash)"

# after everything that touches the prompt
command -v direnv >/dev/null && eval "$(direnv hook bash)"
