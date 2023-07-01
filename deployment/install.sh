#!/bin/sh

# downloads and installs our entire repo on the prod server.

# install nodejs
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
. ~/.nvm/nvm.sh # activate nvm
nvm install --lts

# install pnpm
wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -
source /home/ec2-user/.bashrc

yum install gcc-c++ # needed for node-gyp

# install our mud fork
cd ~
git clone https://github.com/tenetxyz/mud
cd mud
pnpm install
pnpm build