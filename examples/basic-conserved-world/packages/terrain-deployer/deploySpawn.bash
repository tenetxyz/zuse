#!/bin/bash

# Extract worldAddress using awk
worldAddress=$(awk -F'"' '/"31337":/{getline; print $4}' ../world/worlds.json)

# Function to run tsx script
run_tsx_script() {
  local filePath=$1
  local command="yarn run tsx ${filePath}"
  echo "Running command: ${command}"
  # Execute the command and print stdout and stderr to the console
#   eval ${command} &
}

# Iterate over the files in script/generated directory
for file in script/generated/*; do
  if [[ $(basename "$file") == SpawnDeploy_0_2_1* ]]; then
    run_tsx_script "$file"
  fi
done

wait

# echo "Verifying spawn..."
# forge script script/VerifySpawn.s.sol --sig "run(address)" $worldAddress --broadcast --rpc-url http://127.0.0.1:8545
# Uncomment the line below if you want to run the forge script
# run_forge_script script/VerifySpawn.s.sol

