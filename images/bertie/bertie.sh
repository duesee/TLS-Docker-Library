#!/bin/bash
cd "$(dirname "$0")" || exit 1
source ../helper-functions.sh

_docker build -t ${DOCKER_REPOSITORY}bertie-client:latest --target bertie-client .

exit "$EXITCODE"
