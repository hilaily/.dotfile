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

def install_z():
    os.system("git clone --depth=1 https://github.com/skywind3000/z.lua.git /usr/local/z.lua")

def install_git():
    if not cmd_exist("git"):
        print("git is not exist")
    os.system("mv ~/.gitconfig ~/.gitconfig.bak")
    os.system("ln -s ~/.dotfile/git/.gitconfig ~/.gitconfig")

def cmd_exist(name):
    from shutil import which
    return which(name) is not None

install_map = {
    "neovim": install_neovim,
    "z": install_z,
    "git": install_git,
}


if __name__ == '__main__':
    main()
