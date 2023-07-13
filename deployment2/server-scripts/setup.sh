#!/bin/sh

cd ~
unzip dist.zip

# install foundry
curl -L https://foundry.paradigm.xyz | bash
source /home/ec2-user/.bashrc
foundryup