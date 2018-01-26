#!/usr/bin/env bash


#!/usr/bin/env bash

remove_container() {
    echo "Remove container"
    local NAME=$1
    if [ "$(docker ps -f NAME=${NAME} | wc -l)" -gt 1 ]; then
        docker rm ${NAME}
        echo "Remove docker container ${NAME}"
    else
        echo "Not found containers ${NAME}"
    fi
}

while getopts "n" arg;
do
    case ${arg} in
        n)
            remove_container $OPTARG
        ;;
    esac
done
