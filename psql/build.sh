#!/bin/bash
# Pre-req: have the registry set to artifact registry

# Exit early
set -e

echo "Retrieving PSQL secret"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CONNSTR=$(gcloud secrets versions access latest --secret=production-psql)
USERNAME=$(echo $CONNSTR | cut -d '/' -f 3 | cut -d '@' -f 1 | cut -d ':' -f 1)
PASSWORD=$(echo $CONNSTR | cut -d '/' -f 3 | cut -d '@' -f 1 | cut -d ':' -f 2)
NETLOC=$(echo $CONNSTR | cut -d '/' -f 3 | cut -d '@' -f 2 | cut -d ':' -f 1)
PORT=$(echo $CONNSTR | cut -d '/' -f 3 | cut -d '@' -f 2 | cut -d ':' -f 2)
DBNAME=$(echo $CONNSTR | cut -d '/' -f 4 | cut -d '?' -f 1)

echo "Remaking credentials directory"
rm -rf $SCRIPT_DIR/credentials
mkdir $SCRIPT_DIR/credentials

# echo $CONNSTR
echo $USERNAME > $SCRIPT_DIR/credentials/postgres-user
echo $PASSWORD > $SCRIPT_DIR/credentials/postgres-passwd
# echo $NETLOC
# echo $PORT
echo $DBNAME > $SCRIPT_DIR/credentials/postgres-db

echo "Building docker image"
IMAGE_NAME=us-east1-docker.pkg.dev/budget-server-370523/docker-smithers/smithers-psql:1.5
GIT_URL=https://github.com/toiletpapar/smithers-server.git
docker buildx build -t $IMAGE_NAME --no-cache --build-context repo=$GIT_URL $SCRIPT_DIR

# In cmd
# gcloud auth configure-docker us-east1-docker.pkg.dev
# docker push us-east1-docker.pkg.dev/budget-server-370523/docker-smithers/smithers-psql:1.5