#!/bin/sh

# NOTE: you need to run brew install fswatch to use this script

clear && printf '\e[3J'
echo "Listening for changes in *.sol files in the current directory tree"
fswatch -o -r --event Updated --event Created --event Removed --include "\.sol$" --exclude ".*" . | while read num; do
    clear && printf '\e[3J'
    forge build
done
