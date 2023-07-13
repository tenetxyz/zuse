#!/bin/sh

cd ~
unzip dist.zip

# install foundry
curl -L https://foundry.paradigm.xyz | bash
source /home/ec2-user/.bashrc
foundryup

sudo yum install tmux -y
sudo yum install git -y
sudo yum install htop -y

echo "Run the following command:"
echo "source /home/ec2-user/.bashrc"