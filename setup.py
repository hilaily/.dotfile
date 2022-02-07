#!/usr/bin/env python3
import subprocess
import urllib.request
import os
import argparse

home_dir = os.getenv("HOME")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--init", help="init tools", type=str)
    args = parser.parse_args()
    installer = Installer()
    installer.install(args.init)


class Base(object):
    def cmd_exist(self, name):
        from shutil import which
        return which(name) is not None

    def check_link(self, name: str, target: str):
        if os.path.islink(name):
            t = os.readlink(name)
            if t == target:
                return
        os.system("mv %s %s.bak" % (name, name))
        os.system("ln -s %s %s" % (target, name))


class Installer(Base):
    def install(self, val: str):
        if val == "":
            print("install value is empty")
            exit()

        install_map = {
            "brew": self.install_brew,
            "neovim": self.install_neovim,
            "z": self.install_z,
            "git": self.install_git,
            "go": self.install_go,
            "tmux": self.init_tmux,
        }
        if val in install_map:
            install_map.get(val)()
        else:
            print("cmd not support, install: "+val)

    # install neovim
    def install_neovim(self):
        if not self.cmd_exist("nvim"):
            os.chdir("/usr/local")
            os.system(
                "wget https://github.com/neovim/neovim/releases/download/v0.6.0/nvim-macos.tar.gz")
            os.system("tar zxf nvim-macos.tar.gz")
            os.system("ln -s /usr/local/nvim-osx64 /usr/local/nvim")
        self.check_link(home_dir+"/.config/nvim", home_dir+"/.doftile/nvim")

    def install_z(self):
        if not os.path.exists("/usr/local/z.lua"):
            run("git clone --depth=1 https://github.com/skywind3000/z.lua.git /usr/local/z.lua")

    def install_git(self):
        if not self.cmd_exist("git"):
            print("git is not exist")
        self.check_link(home_dir+"/.gitconfig",  home_dir +
                        "/.dotfile/git/.gitconfig")

    def install_go(self):
        cwd = os.getcwd()
        os.chdir("/usr/local")
        if os.path.exists("/usr/local/opt/go/libexec"):
            run("sudo mv go go_old")
            run("sudo ln -s /usr/local/opt/go/libexec /usr/local/go")
        os.chdir(cwd)
        run("go install golang.org/x/tools/gopls@latest")

    def install_brew(self):
        run("/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"")

    def init_tmux(self):
        self.check_link(home_dir+"/.tmux.conf",
                        home_dir+"/.dotfile/.tmux.conf")
        if not os.path.exists(home_dir+"/.tmux/plugins/tmux-resurrect"):
            run("git clone --depth=1 https://github.com/tmux-plugins/tmux-resurrect %s/.tmux/plugins/tmux-resurrect" % (home_dir))


class Base(object):
    def cmd_exist(self, name):
        from shutil import which
        return which(name) is not None

    def check_link(self, name: str, target: str):
        if os.path.islink(name):
            t = os.readlink(name)
            if t == target:
                print("path is right: %s" % name)
                return
        os.system("mv %s %s.bak" % (name, name))
        os.system("ln -s %s %s" % (target, name))


def run(cmd: str):
    subprocess.run(cmd.split())


if __name__ == '__main__':
    main()
