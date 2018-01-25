#!/usr/bin/env bash
set -x

release() {
  FILE=$(dirname "${KEY_FILE}")'/'$(basename "${KEY_FILE}")
  chmod +x ${FILE}
  echo 'Starting build release path='${FILE}
  exec /app/gradlew assembleRelease \
   -Pandroid.injected.signing.store.file=${FILE} \
   -Pandroid.injected.signing.store.password=${STORE_PASSWORD} \
   -Pandroid.injected.signing.key.alias=${KEY_ALIAS} \
   -Pandroid.injected.signing.key.password=${KEY_PASSWORD}
}

case "$1" in
  release)
    shift
    release
    ;;
esac
