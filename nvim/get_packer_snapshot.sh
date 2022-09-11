#!/bin/bash
path="$HOME/.cache/nvim/packer.nvim/lock.json"
rm -rf ${path}

vim +"PackerSnapshot lock.json"
cp -f ${path} .
