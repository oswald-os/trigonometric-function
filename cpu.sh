#!/bin/bash

# Get the number of available cores
TOTAL_CORES=$(nproc)
CORE=""


# Initialize the core_table
core_table=$(jq -n --argjson total_cores "$TOTAL_CORES" '
  reduce range($total_cores) as $i (
    {};
    .["core" + ($i|tostring)] = []
  )
')


# Allocate a core
allocate_core()
{
    local container_id=$1
    local selected_core=""

    # Find a core with the smallest load
    selected_core=$( \
        echo "$core_table" | \
        jq -r '
            to_entries |
            map({key: .key, load: (.value | length)}) |
            sort_by(.load) |
            .[0].key
        '
    )

    # Add the container to the selected core
    core_table=$( \
        echo "$core_table" | \
        jq \
            --arg core "$selected_core" \
            --arg container "$container_id" '
                .[$core] += [$container] // []
            '
    )

    CORE=$selected_core
}


# Deallocate a core
deallocate_core()
{
    local container_id=$1

    # Find the core containing the container and remove it
    core_table=$(echo "$core_table" | jq --arg container "$container_id" '
        with_entries(
            .value |= map(select(. != $container))
        )
    ')
}
