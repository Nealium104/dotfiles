#!/usr/bin/env bash

# Print the installed version of everything the playbook manages next to the
# version it's pinned to (or "latest" when it isn't pinned). Changes nothing.

repo="$(dirname "$(dirname "$(readlink -f "$0")")")"
vars="$repo/ansible/group_vars/all.yml"

# fallbacks for when this isn't run from an interactive shell
PATH="$PATH:$HOME/.cargo/bin:$HOME/.local/bin:/usr/local/go/bin"

# value of a top-level `key: value` line in group_vars, without a leading v
pin() { awk -F': *' -v k="$1" '$1 == k { sub(/^v/, "", $2); print $2 }' "$vars"; }

# first thing that looks like a version number in a command's output
ver() { "$@" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1; }

apt_ver() { dpkg-query -W -f '${Version}' "$1" 2>/dev/null; }

row() {
  local tool=$1 installed=$2 wanted=$3 note=
  if [ -z "$installed" ]; then
    installed=- note=missing
  elif [ "$wanted" != latest ] && [[ "$installed" != ${wanted%x}* ]]; then
    note=differs
  fi
  printf '%-26s %-32s %-10s %s\n' "$tool" "$installed" "$wanted" "$note"
}

printf '%-26s %-32s %-10s\n' TOOL INSTALLED WANTED

row neovim "$(ver nvim --version)" "$(pin neovim_version)"
row go "$(ver go version)" "$(pin go_version)"
row nvm "$(ver bash -c '. "$HOME/.nvm/nvm.sh" && nvm --version')" "$(pin nvm_version)"
row fzf "$(ver fzf --version)" "$(pin fzf_version)"
row yq "$(ver yq --version)" "$(pin yq_version)"
row node "$(ver node --version)" "$(pin node_version).x"

while read -r name bin version; do
  row "$name" "$(ver "$bin" --version)" "$version"
done < <(sed -nE 's/^ *- *\{ *name: *([^, ]+), *bin: *([^, ]+), *version: *([^ }]+) *\}.*/\1 \2 \3/p' "$vars")

row rustc "$(ver rustc --version)" latest
row rust-analyzer "$(ver rust-analyzer --version)" latest
row ansible-lint "$(ver ansible-lint --version)" latest
row ansible-core "$(ver ansible --version)" latest
row composer "$(ver composer --version)" latest
row tpm "$(git -C "$HOME/.tmux/plugins/tpm" log -1 --format='%h %cs' 2>/dev/null)" latest

apt_packages=$(awk '/^packages:/ { on = 1; next } on && /^ *- / { print $2; next } on { exit }' "$vars")
apt_packages+=" gh fastfetch docker-ce"
grep -qi microsoft /proc/version && apt_packages+=" wslu"
for package in $apt_packages; do
  row "$package" "$(apt_ver "$package")" latest
done

# nerd fonts live on the windows side under WSL
choco=/mnt/c/ProgramData/chocolatey/bin/choco.exe
if [ -x "$choco" ]; then
  choco_installed=$(cd /mnt/c && "$choco" list --limit-output 2>/dev/null | tr -d '\r')
  for font in $(sed -nE 's/^ *- *\{ *choco: *([^, ]+),.*/\1/p' "$vars"); do
    row "$font" "$(awk -F'|' -v f="$font" 'tolower($1) == tolower(f) { print $2 }' <<<"$choco_installed")" latest
  done
fi
