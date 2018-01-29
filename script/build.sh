#!/bin/bash

while getopts "n:" arg;
do
    case ${arg} in
        n)
            docker build --tag $OPTARG $(pwd)
        ;;
    esac
done
