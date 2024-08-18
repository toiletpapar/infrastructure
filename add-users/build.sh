#!/bin/bash
set -e

# IMAGE_NAME=us-east1-docker.pkg.dev/budget-server-370523/docker-smithers/add-users:1.9
IMAGE_NAME=registry.smithers.private/add-users:1.9
GIT_URL=https://github.com/toiletpapar/smithers-server.git
# GIT_URL=https://github.com/toiletpapar/smithers-server.git#test
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "SCRIPT DIR: $SCRIPT_DIR"

docker buildx build -t $IMAGE_NAME --build-context repo=$GIT_URL $SCRIPT_DIR

# In cmd
# docker push registry.smithers.private/add-users:1.9

# In cmd
# gcloud auth configure-docker us-east1-docker.pkg.dev
# docker push us-east1-docker.pkg.dev/budget-server-370523/docker-smithers/add-users:1.9