#!/bin/bash

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Step 1: Update APT index
sudo apt update

# Step 2: Install Node.js 14
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt -y install nodejs

# Step 3: Install NPM & Node.js Dev Tools (Optional)
sudo apt -y install gcc g++ make
sudo npm install -g serverless

# Step 4: Install Yarn (Optional)
#curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#sudo apt update && sudo apt install yarn

# Verify Node.js and Yarn versions
node -v
yarn -v
npm -v

echo "Node.js 14 installation completed."

