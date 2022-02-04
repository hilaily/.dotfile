#!/usr/bin/env python3
import subprocess
import urllib.request
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
            "go": self.install_go,
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
    def install_go(self):
        version = urllib.request.urlopen("https://go.dev/VERSION?m=text").read()
        if self.cmd_exist("go"):
            run("go version")
        cwd = os.getcwd()
        os.chdir("/usr/local/")
        name = "%s.darwin-amd64.tar.gz"%(version.decode())
        u="https://dl.google.com/go/"+name
        run("sudo mv go go_old")
        run("sudo rm "+name)
        run("sudo wget "+u)
        run("sudo tar zxf "+name)
        run("go version")
        os.chdir(cwd)
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

def run(cmd:str):
    subprocess.run(cmd.split())






if __name__ == '__main__':
    main()
