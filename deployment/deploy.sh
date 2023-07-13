#!/bin/sh


source server_url.rc


echo "building client"
cd ../packages/client
yarn run build # build the production file
cd ../../ # back in the project's root dir

# -o means options. StrictHostKeyChecking=no will disable asking for "Are you sure you want to continue connecting (yes/no/[fingerprint])?"
# https://askubuntu.com/questions/87449/how-to-disable-strict-host-key-checking-in-ssh
echo "sending built client to the server"
scp -o StrictHostKeyChecking=no -i ~/.ssh/Tenet.pem packages/client/dist.zip "ec2-user@$SERVER_HOST:/home/ec2-user/dist.zip"

echo "sending server scripts"
scp -i ~/.ssh/Tenet.pem -r deployment2/server-scripts/* "ec2-user@$SERVER_HOST:/home/ec2-user/"


# Note: when we build the services below, the go commands are compiling them for linux
echo "building mud services and scping them to the server"
cd ../mud/packages/services

echo "building ecs-snapshot"
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -o ./bin/ecs-snapshot ./cmd/ecs-snapshot
scp -i ~/.ssh/Tenet.pem bin/ecs-snapshot "ec2-user@$SERVER_HOST:/home/ec2-user/ecs-snapshot"
echo "sent ecs-snapshot to the server"

echo "building faucet"
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -o ./bin/faucet ./cmd/faucet
scp -i ~/.ssh/Tenet.pem bin/faucet "ec2-user@$SERVER_HOST:/home/ec2-user/faucet"
echo "sent faucet to the server"

echo "building relay"
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -o ./bin/relay ./cmd/ecs-relay
scp -i ~/.ssh/Tenet.pem bin/relay "ec2-user@$SERVER_HOST:/home/ec2-user/relay"
echo "sent relay to the server"