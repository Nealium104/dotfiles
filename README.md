# dotfiles

My development environment for Ubuntu, mostly under WSL: the tools, and the
configs for them.

## Setup

```sh
git clone https://github.com/Nealium104/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

It asks for the sudo password once and is safe to rerun: anything already
installed at the wanted version is skipped.

## Commands

After the first run, `make` covers everything:

- `make install`: install anything missing or at the wrong version
- `make upgrade`: also bring everything unpinned to its latest release
- `make check`: show what install would change, without changing it
- `make versions`: installed version of every tool next to the wanted one
- `make cleanup`: remove old copies of tools that have been replaced
- `make cleanup-check`: show what cleanup would remove
- `make lint`: shellcheck and ansible-lint

Each is a thin wrapper around `./install.sh`, which passes any other option
straight to `ansible-playbook`.

## How it works

`install.sh` bootstraps Rust, then `uv`, then Ansible, and runs the playbook
in `ansible/setup.yml`. The playbook installs the tools and links the configs
into place.

- **What gets installed** is data, not code: every package list and version
  pin is in `ansible/group_vars/all.yml`. To add a tool or bump a version,
  edit that file and run `make install`.
- **Configs** are the top-level directories (`bash/`, `nvim/`, `git/`, ...).
  Each is a [stow](https://www.gnu.org/software/stow/) package laid out as it
  should appear under `~`. To add one, create the directory, add it to
  `stow_packages`, and add its path to the conflict check in `setup.yml`.
- **Replaced tools** go in `ansible/cleanup.yml`, which removes an old copy
  only once its replacement exists.

## On WSL

Fonts and WezTerm are installed on the Windows side with Chocolatey, which
raises UAC prompts. `/etc/wsl.conf` and the Windows `.wslconfig` are written
too; changes to those need `wsl --shutdown`, and on a fresh distro the first
run stops after writing them and asks for that.
