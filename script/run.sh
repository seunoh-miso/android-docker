#!/usr/bin/env bash

already_remove() {
    if [ "$(docker ps -f NAME=$NAME | wc -l)" -gt 0 ]; then
        docker rm $NAME
        echo "Delete docker container ${NAME}"
    else
        echo 'Not found containers'
    fi
}

run() {
    already_remove
    id=$(docker create --name ${NAME} -e KEY_FILE=/app/${FILENAME} -e STORE_PASSWORD=miso12 -e KEY_ALIAS=miso -e KEY_PASSWORD=miso12 ${IMAGE} release) \
    && docker cp ${FILE} $id:/app/${FILENAME} \
    && docker start -a -i $id \
    && docker cp $id:/app/app/build/outputs/ $(pwd)/build/outputs/ \
    && docker rm -f -v $id
}

while getopts i:n:f: arg
do
    case $arg in
        i)
            IMAGE=$OPTARG
            echo "option i, argument <$IMAGE>"
        ;;
        n)
            NAME=$OPTARG
            echo "option n, argument <$NAME>"
        ;;
        f)
            FILE=$OPTARG
            FILENAME=$(basename "$FILE")
            echo "option f, argument <$OPTARG>, $FILENAME"
        ;;
    esac
done

run
