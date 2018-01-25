#!/usr/bin/env bash

remove_container() {
    C=$(docker ps -q -a | wc -l)
    if [ "${C}" -gt 1 ]; then
        docker rm $(docker images | grep "^<none>" | awk '{ print $3 }')
        docker rm $(docker images -f "dangling=true" -q)
    else
        echo 'Not found containers'
    fi
}

remove_images() {
    I=$(docker images -q -a | wc -l)
    if [ "${I}" -gt 1 ]; then
        docker rmi -f $(docker images | grep "^<none>" | awk '{ print $3 }')
        docker rmi -f $(docker images -f "dangling=true" -q)
    else
        echo 'Not found images'
    fi
}


remove_container
remove_images


