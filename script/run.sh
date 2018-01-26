#!/usr/bin/env bash

IMAGE=""
NAME=""
BUILD=""
FILE=""
STORE_PASSWORD=""
KEY_ALIAS=""
KEY_PASSWORD=""

usage() {
    echo "Usage: $0 [OPTION...]"
    echo '\t-i ; Set docker build image name (required)'
    echo '\t-n ; Set docker container name (required)'
    echo '\t-b ; Set build type in android (required)'
    echo '\t-f ; Set android keystore file'
    echo '\t-s ; Set a secure password for your keystore'
    echo '\t-a ; Set an identifying name for your key'
    echo '\t-k ; Set secure password for your key.'
    exit 1
}

run() {
    echo "Remove docker container: ${NAME}"
    docker ps -q --filter name=${NAME} | grep -q . && docker rm ${NAME}

    local FILENAME=$(basename ${FILE})
    local ID=$(docker create --name ${NAME} \
     -e KEY_FILE=/app/${FILENAME} \
     -e STORE_PASSWORD=${STORE_PASSWORD} \
     -e KEY_ALIAS=${KEY_ALIAS} \
     -e KEY_PASSWORD=${KEY_PASSWORD} \
     ${IMAGE} \
     ${BUILD}
     )

    echo "Created container ${ID}"

    echo "Copy to container ${FILE}"
    docker cp ${FILE} ${ID}:/app/${FILENAME}

    echo "Start container"
    docker start -a -i ${ID}

    echo "Copy from container to Host"
    docker cp ${ID}:/app/app/build/outputs/ $(pwd)/outputs/

    echo "Remove container"
    docker rm -f -v ${ID}
    echo 'Finished'
}

while getopts "i:n:b:f:s:a:k:" opt; do
    case ${opt} in
    i)
        IMAGE=${OPTARG}
    ;;
    n)
        NAME=${OPTARG}
    ;;
    b)
        BUILD=${OPTARG}
    ;;
    f)
        FILE=${OPTARG}
    ;;
    s)
        STORE_PASSWORD=${OPTARG}
    ;;
    a)
        KEY_ALIAS=${OPTARG}
    ;;
    k)
        KEY_PASSWORD=${OPTARG}
    ;;
    \?)
    echo "Invalid option: -$OPTARG"
    usage
    ;;
    esac
done

if [[ "${NAME}" && "${BUILD}" && "${IMAGE}" ]]; then
  run
  else
  echo "Invalid option:"
  usage
fi
