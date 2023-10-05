#!/usr/bin/env bash

# Define a function to handle the concurrent command
run_example() {
    local path="$1"
    local extra_cmd="$2"
    local command="cd examples/${path} && yarn run dev"
    if [[ -n "$extra_cmd" ]]; then
        command="${command} && ${extra_cmd}"
    fi
    echo $command
    concurrently -n example -c \#fb8500 "$command"
}

# Check if the first argument is "run"
if [[ "$1" == "run" ]]; then
    case "$2" in
        "dev")
            concurrently -n anvil,contracts,client -c blue,green,white "./t run dev:anvil" "./t run dev:framework $4 && ./t run dev:$3"  "./t run dev:client"
            ;;
        "dev-no-client")
            concurrently -n anvil,contracts -c blue,green,white "./t run dev:anvil" "./t run dev:framework $4 && ./t run dev:$3 $4 $5"
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
            run_example "basic-world"
            ;;
        "dev:basic-agent-world")
            run_example "basic-agent-world"
            ;;
        "dev:basic-conserved-world")
            extra_cmd=""
            if [[ "$3" == "--with-pokemon" ]] || [[ "$4" == "--with-pokemon" ]]; then
                extra_cmd="yarn run deploy:pokemon"
            fi
            run_example "basic-conserved-world" "$extra_cmd"
            ;;
        "dev:multiple-layers-world")
            run_example "multiple-layers-world"
            ;;
        "dev:spawn-entity")
            cd examples/basic-conserved-world/packages/world && yarn run spawnEntity
            ;;
        "dev:client")
            cd examples/client && yarn run dev
            ;;
        "dev:snapshot")
            sh scripts/rollback/create_snapshot.sh
            echo "rollbacked snapshot"
            ;;
        *)
            echo "Invalid command."
            ;;
    esac
else
    echo "Usage: ./t run [command]"
fi