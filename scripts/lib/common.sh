#!/bin/sh

dir_exist (){
    if [ -d "$1" ];then
        echo "Directory $1 exists."

        return 0;
    else
        echo "Error: Directory $1 does not exists."

        return 1;
    fi
}

file_exist (){
    if test -f "$1"; then
        echo "$1 exists"
    else
        echo "$1 not exist"
    fi
}

logger_write (){
    prefix="$(date +"%m/%d/%Y"):"
    maxSize=90000
    actualSize="$(wc -c < "$1")";

    if [ ! -e "$1" ] || [ "$actualSize" -ge "$maxSize" ]; then
        echo "$prefix $2" > "$1"
    else
        echo "$prefix $2" >> "$1"
    fi
}
