#!/bin/bash

# Build Web 

set -e

if [ -z $GOOS ]; then
	echo "GOOS is not set"
	exit 1
fi
if [ -z $GOARCH ]; then
	echo "GOARCH is not set"
	exit 1
fi

OUTPUT_DIR=${1:-./output/$GOOS-$GOARCH}

cd web 
pnpm install 
pnpm build

cd ..
mkdir -p $OUTPUT_DIR/
rm -rf $OUTPUT_DIR/web/*
mkdir -p $OUTPUT_DIR/web/
cp -r web/out/* $OUTPUT_DIR/web/