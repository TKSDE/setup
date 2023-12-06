#!/bin/bash

# Remove NVM
rm -rf $HOME/.nvm
sed -i '/nvm/d' $HOME/.bashrc
sed -i '/nvm/d' $HOME/.zshrc

# Remove Node.js and npm
nvm deactivate
nvm uninstall --lts
nvm clear-cache
rm -rf $HOME/.npm $HOME/.node-gyp

echo "NVM, Node.js, and npm have been removed from your system."
