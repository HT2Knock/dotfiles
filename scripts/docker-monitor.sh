#!/bin/bash

event () {
    timestamp="$(date "+%Y-%m-%d %H:%M:%S")";

    event_type=$1
    container_id=$2
    name=$(docker inspect --format {{.Name}} $container_id)

    echo "$timestamp: $event_type $name"
}

docker events --filter 'type=container' --filter 'event=create' --filter 'event=restart' --filter 'event=destroy' | while read event
do
    # space character is set as delimiter
    IFS=' '

    # str is read into an array as tokens separated by IFS
    read -ra values <<< "$event"
    echo $event

    #echo each of the value to output
    event "${values[2]}" "${values[3]}"
done;
