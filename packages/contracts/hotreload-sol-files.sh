#!/bin/bash

# Define the directories to be watched
WATCH_PATHS="."

# Define the exclude patterns
EXCLUDE_DIRS=("src/codegen" "cache")

# Define the commands to be run
CMD_SOL="printf '\e[3J' && forge build"
CMD_TS="yarn tablegen && yarn worldgen"

eval $CMD_TS
eval $CMD_SOL

# Create the exclude parameters
EXCLUDE_PARAMS=""
for dir in "${EXCLUDE_DIRS[@]}"; do
  EXCLUDE_PARAMS="${EXCLUDE_PARAMS} --exclude ${dir}"
done

# Start fswatch
fswatch -0 -or --include ".*\.sol$" --include ".*\.ts$" $EXCLUDE_PARAMS $WATCH_PATHS | while read -d "" event
do
  # Extract the file extension
  extension="${event##*.}"
  echo $extension
  
  # Run command after a change is detected, based on file extension
  if [ "$extension" = "sol" ]; then
    eval $CMD_SOL
  elif [ "$extension" = "ts" ]; then
    eval $CMD_TS
    eval $CMD_SOL
  fi
done
