#!/usr/bin/env bash

while getopts "n:" arg;
do
    case ${arg} in
        n)
            docker build --tag $OPTARG -f Dockerfile-Local $(pwd)
        ;;
    esac
done
