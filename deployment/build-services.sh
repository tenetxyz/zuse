#!/bin/sh

# install pnpm
#wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -
#source /home/ec2-user/.bashrc
#
## install our mud fork
#cd ~
#git clone https://github.com/tenetxyz/mud
#cd mud
#pnpm install
#pnpm build

read -p "Enter the server URL: " server_url

cd ../../mud/packages/services
make ecs-snapshot
make faucet
scp -P 2222 bin/faucet "ec2-user@$server_url"