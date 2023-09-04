#!/usr/bin/env bash

# Check if the first argument is "run"
if [[ "$1" == "run" ]]; then
    case "$2" in
        "dev")
            if [[ "$3" == "multiple-layers-world" ]]; then
                concurrently -n anvil,contracts,client -c blue,green,white "./t run dev:anvil" "./t run dev:multiple-layers-world"  "./t run dev:client";
            elif [[ "$3" == "basic-world" ]]; then
                concurrently -n anvil,contracts,client -c blue,green,white "./t run dev:anvil" "./t run dev:basic-world"  "./t run dev:client";
            else
                echo "No/incorrect example world specified."
            fi
            ;;
        "dev-no-client")
            if [[ "$3" == "multiple-layers-world" ]]; then
                concurrently -n anvil,contracts -c blue,green,white "./t run dev:anvil" "./t run dev:multiple-layers-world"
            elif [[ "$3" == "basic-world" ]]; then
                concurrently -n anvil,contracts -c blue,green,white "./t run dev:anvil" "./t run dev:basic-world"
            else
                echo "No/incorrect example world specified."
            fi
            ;;
        "dev:anvil")
            cd scripts && yarn run anvil
            ;;
        "dev:multiple-layers-world")
            yarn run dev && concurrently -n example -c \#fb8500 "cd examples/multiple-layers-world && yarn run dev"
            ;;
        "dev:basic-world")
            yarn run dev && concurrently -n example -c \#fb8500 "cd examples/basic-world && yarn run dev"
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