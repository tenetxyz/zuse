#!/bin/sh

directory="$(cd "$(dirname "$0")" && pwd)"
cast rpc evm_snapshot --rpc-url "http://127.0.0.1:8545" > "$directory/snapshot_id.txt"