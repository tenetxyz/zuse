#!/usr/bin/env bash

# Check if the first argument is "run"
if [[ "$1" == "run" ]]; then
    case "$2" in
        "dev")
            concurrently -n anvil,contracts,client -c blue,green,white "./t run dev:anvil" "./t run dev:framework $4 && ./t run dev:$3"  "./t run dev:client"
            ;;
        "dev-no-client")
            concurrently -n anvil,contracts -c blue,green,white "./t run dev:anvil" "./t run dev:framework $4 && ./t run dev:$3"
            ;;
        "dev:anvil")
            cd scripts && yarn run anvil
            ;;
        "dev:framework")
            case "$3" in
                "--skip-build")
                    yarn run registry
                    ;;
                *)
                    yarn run dev
                    ;;
            esac
            ;;
        "dev:basic-world")
            concurrently -n example -c \#fb8500 "cd examples/basic-world && yarn run dev"
            ;;
        "dev:basic-agent-world")
            concurrently -n example -c \#fb8500 "cd examples/basic-agent-world && yarn run dev"
            ;;
        "dev:basic-conserved-world")
            concurrently -n example -c \#fb8500 "cd examples/basic-conserved-world && yarn run dev"
            ;;
        "dev:multiple-layers-world")
            concurrently -n example -c \#fb8500 "cd examples/multiple-layers-world && yarn run dev"
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