#!/bin/bash

# all name are lowercase
# x86_64 -> amd64

# get os and arch
function get_os_arch() {
    local os_arch=$(get_os)-$(get_arch)
    echo $os_arch
}

function get_os() {
    local os=$(uname -s)
    os=$(echo $os | tr '[:upper:]' '[:lower:]')
    echo $os
}

function get_arch() {
    local arch=$(uname -m)
	arch=$(echo $arch | tr '[:upper:]' '[:lower:]')
	arch=$(echo $arch | sed 's/x86_64/amd64/')
    echo $arch
}