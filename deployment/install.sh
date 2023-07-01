#!/bin/sh

# downloads and installs our entire repo on the prod server.

# install pnpm
wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -
source /home/ec2-user/.bashrc

# install our mud fork
cd ~
git clone https://github.com/tenetxyz/mud
cd mud
pnpm install
pnpm build
