if command -v eza >/dev/null; then
  alias ls='eza'
  alias ll='eza -l --git'
  alias la='eza -la --git'
  alias tree='eza --tree'
fi

if command -v keepassxc-cli >/dev/null; then
    alias kp='keepassxc-cli'
fi
