#!/bin/bash

# Extract worldAddress using awk
worldAddress=$(awk -F'"' '/"31337":/{getline; print $4}' worlds.json)
mainWorldAddress=$(awk -F'"' '/"31337":/{getline; print $4}' ../world/worlds.json)

# Start constructing the command
command="forge script script/TerrainDeploy.s.sol --sig 'run(address,address)' '${worldAddress}' '${mainWorldAddress}' --broadcast --rpc-url http://127.0.0.1:8545 -vv"

# Output the command
echo "Running command: $command"

# Execute the command and display output as it runs
eval $command
