#!/bin/bash

# Define the directories to be watched
WATCH_PATHS="."

# Define the exclude patterns
EXCLUDE_DIRS=("src/codegen" "cache")

# Define the commands to be run
CMD_SOL="clear && printf '\e[3J' && forge build"
CMD_TS="yarn run initialize && $CMD_SOL"
eval $CMD_TS

# Create the exclude parameters
EXCLUDE_PARAMS=""
for dir in "${EXCLUDE_DIRS[@]}"; do
  EXCLUDE_PARAMS="${EXCLUDE_PARAMS} --exclude ${dir}"
done

# by default fswatch includes all directories. so we need to first exclude it all via --exclude ".*"
# https://stackoverflow.com/a/37237681/4647924
handle_sol() {
  fswatch -0 -or --include ".*\.sol$" --exclude ".*" $EXCLUDE_PARAMS $WATCH_PATHS | while read -d "" event
  do
    eval $CMD_SOL
  done
}

handle_ts() {
  fswatch -0 -or --include ".*\.ts$" --exclude ".*" $WATCH_PATHS | while read -d "" event
  do
    eval $CMD_TS
  done
}

# Start both handlers in the background
handle_sol &
handle_ts &

# Wait for both processes to end
wait