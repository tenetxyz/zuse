#!/bin/bash
#!/bin/bash

# Extract worldAddress using awk
worldAddress=$(awk -F'"' '/"31337":/{getline; print $4}' worlds.json)

# Loop over all files in script/bootstraps
for file in script/generated/*.sol; do

  # Start constructing the command
  command="forge script $file --sig 'run(address)' '${worldAddress}' --broadcast --rpc-url http://127.0.0.1:8545 -vv"

  # Output the command
  echo "Running command: $command"

  # Execute the command and display output as it runs
  eval "$command"
done
