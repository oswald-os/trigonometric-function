#!/bin/bash


# Function to make the HTTP request
make_request()
{
    curl 127.0.0.1/compute
}


# Infinite loop to send requests at random intervals between 5 and 10 seconds
while true; do
    # Generate a random number between 5 and 10
    sleep_time=$((RANDOM % 6 + 5))
    make_request &
    sleep $sleep_time
done
