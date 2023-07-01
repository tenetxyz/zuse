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
# make ecs-snapshot
# make ecs-snapshot for linux
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -o ./bin/ecs-snapshot ./cmd/ecs-snapshot
scp -i ~/.ssh/Tenet.pem bin/ecs-snapshot "ec2-user@$server_url:/home/ec2-user/ecs-snapshot"

# make faucet
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -o ./bin/faucet ./cmd/faucet
scp -i ~/.ssh/Tenet.pem bin/faucet "ec2-user@$server_url:/home/ec2-user/faucet"

