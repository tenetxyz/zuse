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

ehco "source /home/ec2-user/.bashrc"