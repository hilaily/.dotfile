#!/bin/bash
version=$(nvim -v | awk 'NR==1{print $2}')

path="$HOME/.cache/nvim/packer.nvim/lock-${version}.json"
rm -rf ${path}

# this command will open vim, and you should quit it manualy
vim +"PackerSnapshot lock-${version}.json"
cp -f ${path} .

echo 'file at '${path}
