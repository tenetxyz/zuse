#!/bin/sh

# Use this command if you just want to host a node on this server
# Note: you'll need to deploy the contracts AND host the client from elsewhere

curl -L https://foundry.paradigm.xyz | bash
source /home/ec2-user/.bashrc
foundryup
anvil --block-time 1 --block-base-fee-per-gas 0 --host 0.0.0.0 --chain-id 31337 --port 8545
