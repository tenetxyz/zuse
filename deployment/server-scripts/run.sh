#!/bin/bash

# function for each task
setup() {
    sh setup.sh
}

run_node() {
    anvil --block-time 1 --block-base-fee-per-gas 0 \
    --host 0.0.0.0 --chain-id 905 --gas-limit 1000000000
}

run_client() {
    cd ~/dist
    python3 -m http.server
}

run_faucet() {
    sh run-faucet.sh
}

run_snapshot() {
    sh run-snapshot.sh
}

run_relay() {
    sh run-relay.sh
}

# main script
while true; do
    echo "Please choose an option from the following:"
    echo "1: Run setup"
    echo "2: Run node"
    echo "3: Run client"
    echo "4: Run faucet"
    echo "5: Run snapshot"
    echo "6: Run relay"
    echo "q: Quit"
    read input

    case "$input" in
        1) setup; break ;;
        2) run_node; break ;;
        3) run_client; break ;;
        4) run_faucet; break ;;
        5) run_snapshot; break ;;
        6) run_relay; break ;;
        q) echo "Quitting..."; break ;;
        *) echo "Invalid option. Please enter a number from 1-6, or 'q' to quit." ;;
    esac
done
