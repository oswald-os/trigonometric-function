#!/bin/bash
source "container.sh"
source "cpu.sh"


max_cpu_usage=80.0
containers=("srv1" "srv2" "srv3" "srv4")
pids=()


# Function to handle SIGINT (CTRL+C)
cleanup()
{
    printf "\nCaught SIGINT (CTRL+C). Cleaning up before exiting...\n"

    for i in "${containers[@]}"; do
        if container_exists "$i"; then
            stop_container "$i"
        fi
    done

    exit 0
}


# Trap SIGINT and call the cleanup function
trap cleanup SIGINT


run_container "${containers[0]}"
container_load_handler "${containers[0]}" "$max_cpu_usage" --no-idle  & pids+=("$!")
container_load_handler "${containers[1]}" "$max_cpu_usage"            & pids+=("$!")
container_load_handler "${containers[2]}" "$max_cpu_usage"            & pids+=("$!")
container_load_handler "${containers[3]}" "$max_cpu_usage" --no-busy  & pids+=("$!")

sleep 10  # Pause

# Check for updates
while true; do
    check_image_update
    sleep 60
done

# Wait for the background processes to finish
wait
