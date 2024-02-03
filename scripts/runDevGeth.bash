#!/bin/bash

# clear dev-chain directory
rm -rf dev-chain

# Start the geth node in the background
geth --datadir dev-chain --dev --dev.gaslimit 2000000000 --rpc.gascap 2000000000 --rpc.txfeecap 0 --miner.gaslimit 2000000000 \
    --http --http.addr 0.0.0.0 --http.vhosts "*" --http.api eth,web3,net --http.port 8545 --http.corsdomain "*" \
    --ws --ws.addr 0.0.0.0 --ws.api eth,web3,net --ws.port 8545 --ws.origins "*"

# Sleep for a few seconds to give the node time to initialize
# sleep 10

# Attach to the geth node and execute the transfer script
# geth --exec "loadScript('transfer.js')" attach ipc:./dev-chain/geth.ipc
