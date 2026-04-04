#!/bin/env bash

sudo apt update

# critical dependencies to use this repo
sudo apt install -y git pipx python3-pip

pipx ensurepath

pipx install --include-deps ansible
