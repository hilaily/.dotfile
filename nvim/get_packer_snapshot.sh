#!/bin/bash
version=$(vim -v | awk 'NR==1{print $2}')

path="$HOME/.cache/nvim/packer.nvim/lock-${version}.json"
rm -rf ${path}

vim +"PackerSnapshot lock-${version}.json"
cp -f ${path} .

echo 'file at '${path}
