#!/bin/bash

# function for each task
setup() {
    sh setup.sh
}

run() {
    sh run-node-and-client.sh
}

run_faucet() {
    ./faucet
}

run_snapshot() {
    ./ecs-snapshot
}

run_relay() {
    ./relay
}

# main script
while true; do
    echo "Please choose an option from the following:"
    echo "1: Run setup"
    echo "2: Run node and client"
    echo "3: Run faucet"
    echo "4: Run snapshot"
    echo "5: Run relay"
    echo "q: Quit"
    read input

    case "$input" in
        1) setup; break ;;
        2) run; break ;;
        3) run_faucet; break ;;
        4) run_snapshot; break ;;
        5) run_relay; break ;;
        q) echo "Quitting..."; break ;;
        *) echo "Invalid option. Please enter a number from 1-5, or 'q' to quit." ;;
    esac
done
