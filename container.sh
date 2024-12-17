#!/bin/bash

IMAGE="oswaldus/httpserver"


# Function to check if a container exists
container_exists()
{
    if [ -z "$1" ]; then
        return 255  # Empty name
    fi

    local container_id=$(docker ps --quiet --filter "name=$1")

    if [ -n "$container_id" ]; then
        return 0  # Container exists
    else
        return 1  # Container does not exist
    fi
}


# Run a container (using the dynamic core allocation)
run_container()
{
    if [ -z "$1" ]; then
        return 255  # Empty name
    fi

    local container_id=$1
    allocate_core "$container_id"

    if [ -n "$CORE" ]; then
        docker run \
            --stop-signal SIGINT \
            --name "$container_id" \
            --detach \
            --rm \
            --cpuset-cpus "${CORE#core}" \
            $IMAGE
    else
        echo "Failed to allocate core for $container_id."
        return 1
    fi

    return 0
}


# Stop a container
stop_container()
{
    if [ -z "$1" ]; then
        return 255  # Empty name
    fi

    local container_id=$1
    docker stop "$container_id"
    deallocate_core "$container_id"

    return 0
}


# Function to check container load
check_container_load()
{
    if [ $# -lt 2 ]; then
        return 255  # Empty name
    fi

    local container_id=$1
    local max_cpu_usage=$2  # Max CPU threshold as percentage
    local load_checks=0     # Loaded server counter
    local unload_checks=0   # Unloaded server counter
    local total_checks=12   # 12 checks for 2 minutes at 10-second intervals

    # Monitor the container for 2 minutes (12 checks)
    # for i in $(seq 1 $total_checks); do
    while true; do

        # Get CPU usage from docker stats
        cpu_usage=$( \
            docker stats \
                --no-stream \
                --format "{{.CPUPerc}}" \
                "$container_id" | \
            sed 's/%//'
        )

        # Check if CPU usage exceeds the threshold
        if (( $(echo "$cpu_usage > $max_cpu_usage" | bc -l) )); then
            ((load_checks++))
            unload_checks=0
        else
            ((unload_checks++))
            load_checks=0
        fi

        # If it has exceeded the threshold for 2 minutes, take action
        # Container busy
        if [[ $load_checks -ge $total_checks ]]; then
            return 1  # Busy

        # Container idle
        elif [[ $unload_checks -ge $total_checks ]]; then
            return 2  # Idle
        fi

        sleep 10
    done

    # return 0;
}


# Function to handle container load (busy or idle)
container_load_handler()
{
    # Define flags
    local busy_flag=1
    local idle_flag=1

    # Reset OPTIND for the next set of options
    OPTIND=1

    # Define options
    local short_opts="B,I"
    local long_opts="no-busy,no-idle"

    # Prepare options
    eval set -- "$( \
        getopt \
        -o "$short_opts" \
        --long "$long_opts" \
        --name "check_container_load" \
        -- "$@"
    )"
    unset short_opts long_opts

    # Parse options
    while true;
    do
      case $1 in
        --)
            break
            ;;
        -i|--no-idle)
            idle_flag=0
            shift
            ;;
        -B|--no-busy)
            busy_flag=0
            shift
            ;;
        *)
            echo "Error: Undefined option parsed."
            exit 1
            ;;
      esac
    done

    # Shift away the parsed options
    shift $OPTIND

    container_id=$1
    echo "$container_id handler is up"

    while true; do
        # Check if the container exists
        if ! container_exists "$container_id"; then
            # echo "Container $container_id does not exist. Sleeping for 10 seconds."
            sleep 10
            continue
        fi

        check_container_load "$@"

        case $? in
            1)
                # echo busy
                if ((! busy_flag)); then
                    continue
                fi

                # Find current container index and launch the next one
                for i in "${!containers[@]}"; do
                    if
                        [[ "${containers[$i]}" == "$container_id" ]] &&
                        ! container_exists "${containers[$((i + 1))]}"
                    then
                        # Run next container
                        echo "$container_id has been busy for a while. Launching a new container..."
                        run_container "${containers[$((i + 1))]}"
                        break
                    fi
                done
                ;;
            2)
                # echo idle
                if ((! idle_flag)); then
                    continue
                fi

                echo "$container_id has been idle for a while. Stopping a container..."
                stop_container $container_id
                ;;
            255)
                echo "Invalid usage: Arguments missing."
                return 255
                ;;
        esac
    done
}


# Function to update and install image
check_image_update()
{
    local pull=$(docker pull "$IMAGE" | grep "Downloaded newer image")

    if [ -n "$pull" ]; then

        echo "Newer image avaible. Updating containers..."

        # Stop all handlers
        echo "Stopping handlers..."
        for pid in "${pids[@]}"; do
            kill "$pid"
        done
        pids=()

        # Start temp server
        echo "Starting temp server..."
        run_container "srv_tmp"
        sleep 10  # Pause

        # Exit all containers
        echo "Exiting all containers..."
        for i in "${containers[@]}"; do
            if container_exists "$i"; then
                stop_container "$i"
            fi
        done

        # Rerun server and handlers
        echo "Rerunning server and handlers..."
        run_container "${containers[0]}"
        container_load_handler "${containers[0]}" "$max_cpu_usage" --no-idle  & pids+=("$!")
        container_load_handler "${containers[1]}" "$max_cpu_usage"            & pids+=("$!")
        container_load_handler "${containers[2]}" "$max_cpu_usage"            & pids+=("$!")
        container_load_handler "${containers[3]}" "$max_cpu_usage" --no-busy  & pids+=("$!")
        sleep 10  # Pause

        # Stop temp server
        echo "Exiting temp server..."
        stop_container "srv_tmp"

        echo "Update completed"
    fi
}
