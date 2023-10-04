#!/bin/sh

# Specify the directory where you want to check for the file
directory="./"

# Check if the file "snapshot_id.txt" does not exist in the specified directory
if [ ! -e "$directory/snapshot_id.txt" ]; then
    echo "snapshot_id.txt does not exist in $directory."
    exit 1  # Exit with an error code (1)
else
    text=$(<"$directory/snapshot_id.txt")
    cast rpc evm_revert "$text" --rpc-url "http://127.0.0.1:8545"

    # Run the cast rpc evm_snapshot command and overwrite the file with its output
    cast rpc evm_snapshot --rpc-url "http://127.0.0.1:8545" > "$directory/snapshot_id.txt"
    echo "snapshot_id.txt has been updated with the latest snapshot."
fi
