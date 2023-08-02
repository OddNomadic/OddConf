#! /bin/bash
# run as sudo for a full system install 

# package/app installation
# -------------------------

# install snap
apt update
apt install snapd

snap install nvim --classic
snap install tmux --classic

# install tmux plugin manager
# https://github.com/tmux-plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# configuration
# -------------------------
# backup original tmux.conf and replace with our own
cp ~/.tmux.conf ~/.tmux.conf.bak
cp ./tmux.conf ~/.tmux.conf

# Install NVChad
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1

# TODO override some of NVChad's files with my own

# .bashrc
# _________________________
echo "alias vim='nvim'" >> ~/.bashrc
echo "export TERM=xterm" >> ~/.bahsrc # this fixed a tmux problem on one machine 
