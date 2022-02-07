#!/usr/bin/env python3
import subprocess
import os
import argparse

home_dir = os.getenv("HOME")
dotfile_dir = home_dir+"/.dotfile"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--init", help="init tools", type=str)
    args = parser.parse_args()
    installer = Installer()
    installer.doInit(args.init)


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
        if os.path.exists(name):
            run("mv %s %s.bak" % (name, name))
        run("ln -s %s %s" % (target, name))

    def brew_install(self, name: str):
        if not self.cmd_exist(name):
            run("brew install "+name)


class Installer(Base):
    def doInit(self, val: str):
        if val == "":
            print("install value is empty")
            exit()

        install_map = {
            "brew": self.install_brew,
            "neovim": self.install_neovim,
            "nvim": self.install_neovim,
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
        self.brew_install("neovim")
        self.check_link(home_dir+"/.config/nvim", dotfile_dir+"/nvim")

    def install_z(self):
        if not os.path.exists("/usr/local/z.lua"):
            run("git clone --depth=1 https://github.com/skywind3000/z.lua.git /usr/local/z.lua")

    def install_git(self):
        self.brew_install("git")
        self.check_link(home_dir+"/.gitconfig",  home_dir +
                        "/.dotfile/git/.gitconfig")

    def install_go(self):
        self.brew_install("go")
        cwd = os.getcwd()
        os.chdir("/usr/local")
        if os.path.exists("/usr/local/opt/go/libexec"):
            run("sudo mv go go_old")
            run("sudo ln -s /usr/local/opt/go/libexec /usr/local/go")
        os.chdir(cwd)
        self.brew_install("gopls")
        self.brew_install("golanglint-ci")

    def install_brew(self):
        run("/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"")

    def init_tmux(self):
        self.brew_install("git")
        self.check_link(home_dir+"/.tmux.conf",
                        home_dir+"/.dotfile/.tmux.conf")
        if not os.path.exists(home_dir+"/.tmux/plugins/tmux-resurrect"):
            run("git clone --depth=1 https://github.com/tmux-plugins/tmux-resurrect %s/.tmux/plugins/tmux-resurrect" % (home_dir))


def run(cmd: str):
    subprocess.run(cmd.split())


if __name__ == '__main__':
    main()
