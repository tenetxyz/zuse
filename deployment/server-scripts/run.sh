#!/bin/bash

# function for each task
setup() {
    sh setup.sh
}

run_node() {
    sh run-node.sh
}

run_client() {
    sh run-client.sh
}

run_faucet() {
    sh run-faucet.sh
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
    echo "5: Run relay"
    echo "q: Quit"
    read input

    case "$input" in
        1) setup; break ;;
        2) run_node; break ;;
        3) run_client; break ;;
        4) run_faucet; break ;;
        5) run_relay; break ;;
        q) echo "Quitting..."; break ;;
        *) echo "Invalid option. Please enter a number from 1-6, or 'q' to quit." ;;
    esac
done
