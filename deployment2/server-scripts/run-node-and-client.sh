#!/bin/sh

# function to kill all child processes
cleanup() {
  jobs -p | xargs kill
}

# trap SIGINT and SIGTERM signals and run cleanup function
# When this process is killed, all child processees will be killed as well
trap cleanup EXIT

# run the chain in a diff thread
anvil --block-time 1 --block-base-fee-per-gas 0 \
    --host 0.0.0.0 --chain-id 905 --gas-limit 1000000000 > /dev/null &

# host the client
cd ~/dist
python3 -m http.server