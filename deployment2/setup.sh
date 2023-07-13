#!/bin/sh

cd ~
unzip dist.zip

# install foundry
curl -L https://foundry.paradigm.xyz | bash
source /home/ec2-user/.bashrc
foundryup

# run the chain in a diff thread
anvil --block-time 1 --block-base-fee-per-gas 0 \
    --host 0.0.0.0 --chain-id 905 --gas-limit 1000000000 > /dev/null &

# host the client
cd ~/dist
python3 -m http.server