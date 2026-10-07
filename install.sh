#!/usr/bin/env bash

set -e

repo="$(dirname "$(readlink -f "$0")")"

# --versions prints what's installed and exits without changing anything.
# --upgrade also upgrades every tool that isn't pinned.
# --cleanup runs cleanup.yml (removes replaced tools) instead of setup.yml.
# anything else is passed straight to ansible-playbook
upgrade=false
playbook=setup.yml
args=()
for arg in "$@"; do
  case "$arg" in
    --versions) exec "$repo/scripts/versions.sh" ;;
    --upgrade)
      upgrade=true
      args+=(-e upgrade=true)
      ;;
    --cleanup) playbook=cleanup.yml ;;
    *) args+=("$arg") ;;
  esac
done

sudo apt update

# critical dependencies to use this repo
sudo apt install -y git pipx python3-pip

pipx ensurepath

pipx install --include-deps ansible

if $upgrade; then
  pipx upgrade --include-injected ansible
fi

# pipx's bin dir isn't on PATH yet in this shell on a fresh machine
export PATH="$HOME/.local/bin:$PATH"

# run from ansible/ so ansible.cfg is picked up
cd "$repo/ansible" || exit 1

# this playbook has no vaulted content; .bashrc points ansible at a vault
# password script that may not exist on this machine, which is a hard error
unset ANSIBLE_VAULT_PASSWORD_FILE

ansible-playbook --ask-become-pass "${args[@]}" "$playbook"
