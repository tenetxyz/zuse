#!/usr/bin/env bash

# Check if the first argument is "run"
if [[ "$1" == "run" ]]; then
    case "$2" in
        "dev")
            concurrently -n anvil,contracts,client -c blue,green,white "./t run dev:anvil" "./t run dev:contracts"  "./t run dev:client"
            ;;
        "dev-no-client")
            # Replace this with the command you want to execute for ./t run dev-no-client
            concurrently -n anvil,contracts -c blue,green,white "./t run dev:anvil" "./t run dev:contracts"
            ;;
        "dev:anvil")
            # Replace this with the command you want to execute for ./t run dev-no-client
            cd scripts && yarn run anvil
            ;;
        "dev:contracts")
            # Replace this with the command you want to execute for ./t run dev-no-client
            yarn run dev && concurrently -n example -c \#fb8500 "cd examples/multiple-layers-world && yarn run dev"
            ;;
        "dev:client")
            # Replace this with the command you want to execute for ./t run client
            cd examples/client && yarn run dev
            ;;
        *)
            echo "Invalid command."
            ;;
    esac
else
    echo "Usage: ./t run [command]"
fi