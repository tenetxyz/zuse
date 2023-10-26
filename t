#!/usr/bin/env bash

cur_directory="$(cd "$(dirname "$0")" && pwd)"

# Define a function to handle the concurrent command
run_example() {
    local path="$1"
    local extra_cmd="$2"
    local command="cd examples/${path} && yarn run dev"
    if [[ -n "$extra_cmd" ]]; then
        command="${command} ${extra_cmd}"
    fi
    echo $command
    yarn concurrently -n example -c \#fb8500 "$command"
}

# Check if the first argument is "run"
if [[ "$1" == "run" ]]; then
    case "$2" in
        "dev")
            yarn concurrently -n anvil,contracts,client -c blue,green,white "./t run dev:anvil" "./t run dev:framework $4 && ./t run dev:$3"  "./t run dev:client"
            ;;
        "dev-no-client")
            yarn concurrently -n anvil,contracts -c blue,green,white "./t run dev:anvil" "./t run dev:framework $4 && ./t run dev:$3 $4 $5 $6 $7"
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
        "dev:basic-conserved-world")
            extra_cmd=""
            if [[ "$3" == "--with-extensions" ]] || [[ "$4" == "--with-extensions" ]]; then
                extra_cmd="&& yarn run deploy:extensions"
            fi
            if [[ "$4" == "--with-pokemon" ]] || [[ "$5" == "--with-pokemon" ]]; then
                extra_cmd="${extra_cmd} && yarn run deploy:pokemon"
            fi
            if [[ "$4" == "--with-derived" ]] || [[ "$5" == "--with-derived" ]]; then
                extra_cmd="${extra_cmd} && yarn run deploy:derived"
            fi
            if [[ "$4" == "--snapshot" ]] || [[ "$5" == "--snapshot" ]] || [[ "$6" == "--snapshot" ]] || [[ "$7" == "--snapshot" ]]; then
                extra_cmd="${extra_cmd} && sh ${cur_directory}/scripts/rollback/create_snapshot.sh"
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
