#!/bin/sh


read -p "Enter the server URL: " server_url

# -o means options. StrictHostKeyChecking=no will disable asking for "Are you sure you want to continue connecting (yes/no/[fingerprint])?"
# https://askubuntu.com/questions/87449/how-to-disable-strict-host-key-checking-in-ssh
echo "sending built client to the server"
scp -o StrictHostKeyChecking=no -i ~/.ssh/Tenet.pem ../packages/client/dist.zip "ec2-user@$server_url:/home/ec2-user/dist.zip"

# # build MUD services and scps them to the linux environment
# cd ../../mud/packages/services
# # make ecs-snapshot for linux
# CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -o ./bin/ecs-snapshot ./cmd/ecs-snapshot
# scp -i ~/.ssh/Tenet.pem bin/ecs-snapshot "ec2-user@$server_url:/home/ec2-user/ecs-snapshot"

# # make faucet for linux
# CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -o ./bin/faucet ./cmd/faucet
# scp -i ~/.ssh/Tenet.pem bin/faucet "ec2-user@$server_url:/home/ec2-user/faucet"

