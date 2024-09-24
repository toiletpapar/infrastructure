#!/bin/bash
set -e

IMAGE_NAME=registry.smithers.private/smithers-web:1.10
GIT_URL=https://github.com/toiletpapar/smithers-expo.git
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "SCRIPT DIR: $SCRIPT_DIR"

docker buildx build -t $IMAGE_NAME --build-context repo=$GIT_URL $SCRIPT_DIR

# In cmd (baremetal)
# docker push registry.smithers.private/smithers-web:1.10