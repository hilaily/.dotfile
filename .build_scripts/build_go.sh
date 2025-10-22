#!/bin/bash

# Build Go binary
# Args:
# 1. OUTPUT_DIR: output directory, default is ./output, the full output directory is $OUTPUT_DIR/$GOOS-$GOARCH

set -e

OUTPUT_DIR=${1:-./output}

mkdir -p $OUTPUT_DIR/$GOOS-$GOARCH
go build -o $OUTPUT_DIR/$GOOS-$GOARCH/server ./cmd/