#!/usr/bin/env bash

# Check if the first argument is "run"
if [[ "$1" == "run" ]]; then
    case "$2" in
        "dev")
            concurrently -n anvil,contracts,client -c blue,green,white "./t run dev:anvil" "./t run dev:$3"  "./t run dev:client"
            ;;
        "dev-no-client")
            concurrently -n anvil,contracts -c blue,green,white "./t run dev:anvil" "./t run dev:$3"
            ;;
        "dev:anvil")
            cd scripts && yarn run anvil
            ;;
        "dev:framework")
            yarn run dev
            ;;
        "dev:basic-world")
            ./t run dev:framework && concurrently -n example -c \#fb8500 "cd examples/basic-world && yarn run dev"
            ;;
        "dev:basic-agent-world")
            ./t run dev:framework && concurrently -n example -c \#fb8500 "cd examples/basic-agent-world && yarn run dev"
            ;;
        "dev:basic-conserved-world")
            yarn run registry && concurrently -n example -c \#fb8500 "cd examples/basic-conserved-world && yarn run dev"
            ;;
        "dev:multiple-layers-world")
            ./t run dev:framework && concurrently -n example -c \#fb8500 "cd examples/multiple-layers-world && yarn run dev"
            ;;
        "dev:client")
            cd examples/client && yarn run dev
            ;;
        *)
            echo "Invalid command."
            ;;
    esac
else
    echo "Usage: ./t run [command]"
fi