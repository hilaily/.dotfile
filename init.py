#!/usr/bin/env python3
import os
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i","--install", help="install tools",type=str)
    args = parser.parse_args()
    install_val = args.install
    if install_val == "":
        print("install value is empty")
        exit()
    if install_val in install_map:
        install_map.get(args.install)()
    else:
        print("cmd not support, install: "+args.install)


# install neovim
def install_neovim():
    os.chdir("/usr/local")
    os.system("wget https://github.com/neovim/neovim/releases/download/v0.6.0/nvim-macos.tar.gz")
    os.system("tar zxf nvim-macos.tar.gz")
    os.system("ln -s /usr/local/nvim-osx64 /usr/local/nvim")

install_map = {
    "neovim": install_neovim,
}


if __name__ == '__main__':
    main()
