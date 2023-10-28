#!/bin/bash

# Extract worldAddress using awk
worldAddress=$(awk -F'"' '/"1337":/{getline; print $4}' worlds.json)

# Start constructing the command
command="yarn mud test --worldAddress='${worldAddress}' --forgeOptions='-vvv"

# Conditionally append the user-provided test option
if [[ -n "$1" ]]; then
  command+=" $1'"
else
  command+="'"
fi

# Output the command
echo "Running command: $command"

# Execute the command and display output as it runs
eval $command
