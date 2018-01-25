#!/usr/bin/env bash

already_remove() {
    if [ "$(docker ps -f NAME=${NAME} | wc -l)" -gt 0 ]; then
        docker rm ${NAME}
        echo "Delete docker container ${NAME}"
    else
        echo 'Not found containers'
    fi
}

run() {
    echo "Delete container"
    already_remove

    ID=$(docker create --name ${NAME} \
     -e KEY_FILE=/app/${FILENAME} \
     -e STORE_PASSWORD=miso12 \
     -e KEY_ALIAS=miso \
     -e KEY_PASSWORD=miso12 \
     ${IMAGE} \
     ${BUILD}
     )
    echo "Created container ${ID}"
    echo "Copy to container"
    docker cp ${FILE} ${ID}:/app/${FILENAME}
    echo "Start container"
    docker start -a -i ${ID}
    echo "Copy from container to Host"
    docker cp ${ID}:/app/app/build/outputs/ $(pwd)/build/outputs/
    echo "Remove container"
    docker rm -f -v ${ID}
}

while getopts "i:n:b:f:" arg;
do
    case ${arg} in
        i)
            IMAGE=$OPTARG
            echo "option i, argument <$IMAGE>"
        ;;
        n)
            NAME=$OPTARG
            echo "option n, argument <$NAME>"
        ;;
        b)
            BUILD=$OPTARG
            echo "option b, argument <$BUILD>"
        ;;
        f)
            FILE=$OPTARG
            FILENAME=$(basename "$FILE")
            echo "option f, argument <$OPTARG>, $FILENAME"
        ;;
            *)
            echo "$@"
            ;;
    esac
done

run
