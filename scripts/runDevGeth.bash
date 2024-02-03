#!/bin/bash

# clear dev-chain directory
# rm -rf dev-chain

# Start the geth node
# geth --datadir dev-chain --dev --dev.period 1 --dev.gaslimit 2000000000 --rpc.gascap 2000000000 --rpc.txfeecap 0 --miner.gaslimit 2000000000 \
#     --http --http.addr 0.0.0.0 --http.vhosts "*" --http.api eth,web3,net,txpool,miner --http.port 8545 --http.corsdomain "*" \
#     --ws --ws.addr 0.0.0.0 --ws.api eth,web3,net --ws.port 8545 --ws.origins "*"

# geth account new --datadir data
# genesis.json
# geth init --datadir data genesis.json
# bootnode -genkey boot.key
# bootnode -nodekey boot.key -addr :30305
geth --datadir data --port 30306 --bootnodes enode://750fa7b17a9e870dad9d3d1afedfb500f268ed617794b7155f5133e45f3453d32e5395288b20b44c23eb0a0f93685a387d61e60fc70eca9ba1aa64902c731e3f@127.0.0.1:0?discport=30305 --networkid 1337 --unlock 0x328e85cEacB7B9bA2Bc5776338E9bF902B7a801e --password data/password.txt --authrpc.port 8551 --mine --miner.etherbase 0x328e85cEacB7B9bA2Bc5776338E9bF902B7a801e \
    --rpc.gascap 2000000000 --rpc.txfeecap 0 --miner.gaslimit 2000000000 \
    --allow-insecure-unlock \
    --http --http.addr 0.0.0.0 --http.vhosts "*" --http.api eth,web3,net,txpool,miner --http.port 8545 --http.corsdomain "*" \
    --ws --ws.addr 0.0.0.0 --ws.api eth,web3,net --ws.port 8545 --ws.origins "*"
