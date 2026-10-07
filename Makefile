# shortcuts for install.sh. on a brand new machine run ./install.sh directly:
# make itself is one of the things it installs

.PHONY: help install upgrade check versions cleanup cleanup-check lint

help: ## list these commands
	@awk -F':.*## ' '/^[a-z-]+:.*## / { printf "  make %-14s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

install: ## install anything missing or at the wrong version
	./install.sh

upgrade: ## also bring everything unpinned to its latest release
	./install.sh --upgrade

check: ## show what install would change, without changing it
	./install.sh --check --diff

versions: ## installed version of every tool next to the wanted one
	./install.sh --versions

cleanup: ## remove old copies of tools that have been replaced
	./install.sh --cleanup

cleanup-check: ## show what cleanup would remove
	./install.sh --cleanup --check

lint: ## shellcheck and ansible-lint
	shellcheck --severity=warning install.sh scripts/*.sh
	ansible-lint ansible/
