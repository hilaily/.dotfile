#!/bin/bash

# Build Go binary
# Args:
# 1. OUTPUT_DIR: output directory, default is ./output, the full output directory is $OUTPUT_DIR/$GOOS-$GOARCH

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

mkdir -p $OUTPUT_DIR/
go build -o $OUTPUT_DIR/server ./cmd/

if [ -d ./conf ]; then
	mkdir -p $OUTPUT_DIR/conf/
	cp -r ./conf/* $OUTPUT_DIR/conf/
fi

if [ -d ./scripts ]; then
	mkdir -p $OUTPUT_DIR/scripts/
	cp -r ./scripts/* $OUTPUT_DIR/scripts/
fi

if [ -f ./scripts/Makefile ]; then
	cp ./scripts/Makefile $OUTPUT_DIR/
fi