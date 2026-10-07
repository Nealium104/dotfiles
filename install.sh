#!/usr/bin/env bash

set -e

repo="$(dirname "$(readlink -f "$0")")"

# --versions prints what's installed and exits without changing anything.
# --upgrade also upgrades every tool that isn't pinned.
# --cleanup runs cleanup.yml (removes replaced tools) instead of setup.yml.
# anything else is passed straight to ansible-playbook (e.g. --check)
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
    --cleanup | --clean) playbook=cleanup.yml ;;
    -h | --help)
      echo "usage: install.sh [--versions | --cleanup] [--upgrade] [ansible-playbook options, e.g. --check]"
      exit 0
      ;;
    *) args+=("$arg") ;;
  esac
done

# ask for the sudo password once and hand it to ansible. sudo's own cache
# can't cover ansible: sudo remembers a password per terminal, and ansible runs
# its tasks in a session of their own, detached from this one. skipped when
# sudo doesn't want a password (-k first, so a cached one doesn't count)
sudo -k
if ! sudo -n true 2>/dev/null; then
  read -rsp "[sudo] password for $USER: " become_pass
  echo
  if ! sudo -S -p '' -v <<<"$become_pass"; then
    echo "install.sh: sudo didn't accept that password" >&2
    exit 1
  fi
fi

# value of a top-level `key: value` line in group_vars
pin() { awk -F': *' -v k="$1" '$1 == k { print $2 }' "$repo/ansible/group_vars/all.yml"; }

# the bootstrap, in order: rust, then uv fetched with it, then ansible run from
# uv. ansible installs everything else. each step is skipped when it's already
# there; the playbook keeps rust and uv at their wanted versions after that

# the playbook refreshes the apt cache itself, so this is only for a machine
# that doesn't have these yet. the compiler is for tools with no release binary
need=()
command -v git >/dev/null || need+=(git)
command -v curl >/dev/null || need+=(curl)
command -v cc >/dev/null || need+=(build-essential)
command -v cmake >/dev/null || need+=(cmake)
[ -x /usr/bin/python3 ] || need+=(python3)
if [ "${#need[@]}" -gt 0 ]; then
  sudo apt update
  sudo apt install -y "${need[@]}"
fi

# neither bin dir is on PATH yet in this shell on a fresh machine
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

if [ ! -x "$HOME/.cargo/bin/cargo" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi

# cargo-binstall fetches a rust tool's release binary instead of compiling it,
# and compiles only when the project doesn't publish one
binstall_version=$(pin binstall_version)
if [ "$(cargo binstall -V 2>/dev/null)" != "${binstall_version#v}" ]; then
  curl -L --proto '=https' --tlsv1.2 -sSf \
    https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh |
    BINSTALL_VERSION=$binstall_version bash
fi

# the version pinned in cargo_packages
if [ ! -x "$HOME/.cargo/bin/uv" ]; then
  uv_version=$(sed -nE 's/^ *- *\{ *name: *uv, .*version: *([^ }]+) *\}.*/\1/p' "$repo/ansible/group_vars/all.yml")
  cargo binstall --no-confirm --locked --strategies crate-meta-data,compile "uv@$uv_version"
fi

# ansible-playbook belongs to ansible-core; the ansible package beside it adds
# the community collections. --force takes over commands an earlier pipx
# install linked into ~/.local/bin. the distro's python, because left to itself
# uv prefers any python it has downloaded for a project, however old
if [ ! -d "$HOME/.local/share/uv/tools/ansible-core" ]; then
  uv tool install --force --python /usr/bin/python3 --with ansible ansible-core
fi

if $upgrade; then
  uv tool upgrade ansible-core
fi

# run from ansible/ so ansible.cfg is picked up
cd "$repo/ansible" || exit 1

# this playbook has no vaulted content; .bashrc points ansible at a vault
# password script that may not exist on this machine, which is a hard error
unset ANSIBLE_VAULT_PASSWORD_FILE

# ansible only takes the password from a real file. it's readable by this user
# alone, kept in memory rather than on disk where the system has a runtime
# directory, and removed when this script exits
if [ -n "${become_pass+set}" ]; then
  pass_file=$(umask 077 && mktemp -p "${XDG_RUNTIME_DIR:-/tmp}" install-become.XXXXXX)
  trap 'rm -f "$pass_file"' EXIT
  printf '%s\n' "$become_pass" > "$pass_file"
  args+=(--become-password-file "$pass_file")
fi

ansible-playbook "${args[@]}" "$playbook"
