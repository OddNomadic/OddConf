#! /bin/bash
# run as sudo for a full system install 

# package/app installation
# -------------------------

# install snap
sudo apt update
sudo apt install snapd

sudo snap install nvim --classic
sudo snap install tmux --classic

# install tmux plugin manager
# https://github.com/tmux-plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# configuration
# -------------------------
# backup original tmux.conf and replace with our own
cp ~/.tmux.conf ~/.tmux.conf.bak
cp ./tmux.conf ~/.tmux.conf

# Install NVChad
#git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
mkdir -p ~/.config/nvim
cp -r nvim ~/.config/nvim

# TODO override some of NVChad's files with my own

# .bashrc
# _________________________
echo "alias vim='nvim'" >> ~/.bashrc
#echo "export TERM=xterm" >> ~/.bahsrc # this fixed a tmux problem on one machine 
