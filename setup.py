#!/usr/bin/env python3
import os
import argparse

home_dir = os.getenv("HOME")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i","--install", help="install tools",type=str)
    args = parser.parse_args()
    installer = Installer()
    installer.install(args.install)

class Base(object):
    def cmd_exist(self, name):
        from shutil import which
        return which(name) is not None

    def check_link(self, name:str,target:str):
        if os.path.islink(name):
            t = os.readlink(name)
            if t == target:
                return
        os.system("mv %s %s.bak"%(name,name))
        os.system("ln -s %s %s"%(target,name))
class Installer(Base):
    def install(self, val:str):
        if val== "":
            print("install value is empty")
            exit()
            
        install_map = {
            "neovim": self.install_neovim,
            "z": self.install_z,
            "git": self.install_git,
            "packer": self.install_packer,
        }
        if val in install_map:
            install_map.get(val)()
        else:
            print("cmd not support, install: "+val)


    # install neovim
    def install_neovim(self):
        if not self.cmd_exist("nvim"):
            os.chdir("/usr/local")
            os.system("wget https://github.com/neovim/neovim/releases/download/v0.6.0/nvim-macos.tar.gz")
            os.system("tar zxf nvim-macos.tar.gz")
            os.system("ln -s /usr/local/nvim-osx64 /usr/local/nvim")
        self.check_link(home_dir+"/.config/nvim",home_dir+"/.doftile/nvim")

    def install_z(self):
        if not os.path.exists("/usr/local/z.lua"):
            os.system("git clone --depth=1 https://github.com/skywind3000/z.lua.git /usr/local/z.lua")

    def install_git(self):
        if not self.cmd_exist("git"):
            print("git is not exist")
        self.check_link(home_dir+"~/.gitconfig",  home_dir+"/.dotfile/git/.gitconfig")

    def install_packer(self):
        if not os.path.exists(home_dir+"/.local/share/nvim/site/pack/packer/start/packer.nvim"):
            os.system("git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim")
        else:
            print("packer already installed")
class Base(object):
    def cmd_exist(self, name):
        from shutil import which
        return which(name) is not None

    def check_link(self, name:str,target:str):
        if os.path.islink(name):
            t = os.readlink(name)
            if t == target:
                print("path is right: %s"%name)
                return
        os.system("mv %s %s.bak"%(name,name))
        os.system("ln -s %s %s"%(target,name))






if __name__ == '__main__':
    main()
