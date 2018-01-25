#!/usr/bin/env bash
set -x

release() {
  chmod +x ${KEY_FILE}
  echo "Starting build release path=`${KEY_FILE}`"
  exec /app/gradlew assembleRelease \
   -Pandroid.injected.signing.store.file=${KEY_FILE} \
   -Pandroid.injected.signing.store.password=${STORE_PASSWORD} \
   -Pandroid.injected.signing.key.alias=${KEY_ALIAS} \
   -Pandroid.injected.signing.key.password=${KEY_PASSWORD}
}

case "$1" in
  release)
    shift
    release
    ;;
  *)
    exec "$@"
    ;;
esac
