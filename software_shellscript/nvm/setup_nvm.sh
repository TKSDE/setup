#!/bin/bash

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Reload the shell configuration
source ~/.bashrc

# Install the latest LTS version of Node.js using nvm
nvm install --lts

