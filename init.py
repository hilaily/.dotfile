import os

# install neovim
os.chdir("/usr/local")
os.system("wget https://github.com/neovim/neovim/releases/download/v0.6.0/nvim-macos.tar.gz")
os.system("tar zxf nvim-macos.tar.gz")
