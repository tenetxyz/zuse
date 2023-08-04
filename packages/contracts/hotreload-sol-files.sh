#!/bin/sh

# NOTE: you need to run brew install fswatch to use this script

yarn tablegen
yarn worldgen
clear && printf '\e[3J'

# Start in the background a loop that runs echo hi when any .ts files change
echo "Listening for changes in *.ts files in the current directory tree"
fswatch -o -r --event Updated --event Created --event Removed --include "\.ts$" --exclude "src/codegen/*" . | ( while read num; do
    clear && printf '\e[3J'
    echo hi
done ) &

trap 'kill $(jobs -p)' EXIT

echo "Listening for changes in *.sol files in the current directory tree"
fswatch -o -r --event Updated --event Created --event Removed --include "\.sol$" --exclude "src/codegen/*" . | while read num; do
    clear && printf '\e[3J'
    forge build
done
