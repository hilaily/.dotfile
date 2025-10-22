#!/bin/bash

# Build Docker image
# Args:
# 1. IMAGE_NAME: image name, required
# 2. DOCKER_FILE: docker file, default is Dockerfile

set -e

IMAGE_NAME=$1
DOCKER_FILE=${2:-Dockerfile}

if [ -z "$IMAGE_NAME" ]; then
	echo "IMAGE_NAME is not set"; 
	exit 1;
fi;

VERSION=$(cat VERSION);
echo "Building image: $IMAGE_NAME:$VERSION with Dockerfile: $DOCKER_FILE";
docker build -t $IMAGE_NAME:$VERSION -f $DOCKER_FILE .;
docker push $IMAGE_NAME:$VERSION;
if [[ "$VERSION" != *"-"* ]]; then
	echo "This is a stable release, also tagging as latest";
	docker tag $IMAGE_NAME:$VERSION $IMAGE_NAME:latest;
	docker push $IMAGE_NAME:latest;
	echo "Latest tag pushed successfully";
else
	echo "This is a pre-release version, skipping latest tag";
fi;
echo "Image built and pushed successfully: $IMAGE_NAME:$VERSION"