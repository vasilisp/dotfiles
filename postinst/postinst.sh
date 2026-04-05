#!/bin/sh

# Laptop setup on top of a fresh Ubuntu Server 20.04 installation

# This script shouldn't be run as root. We explicitly call sudo
# wherever needed. Inspect `grep sudo: /var/log/auth.log` once done.

# Despite its name, I find the "server" installation appropriate for
# personal machines. Most dependencies of the ubuntu-server
# metapackage are useful or necessary, and git is helpfully there from
# the beginning. The few annoying packages are easy to disable
# (notably cloud-init; see below). mini.iso is deprecated anyway.

set -e

NET=${NET:-wlp3s0}

cd

# precondition: system directories exist; avoid a few `sudo mkdir -p`

[ -d /etc/apt/apt.conf.d ]

# dotfiles setup

[ -f "$HOME/dotfiles/postinst/postinst-dot.sh" ] &&
    sh "$HOME/dotfiles/postinst/postinst-dot.sh" -x

# sane APT

echo 'APT::Install-Recommends "false";' \
    | sudo tee /etc/apt/apt.conf.d/99rec

sudo tee /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

# disable chromium history

[ -d /etc/chromium-browser/policies/managed ] ||
    sudo mkdir -p /etc/chromium-browser/policies/managed

echo '{"SavingBrowserHistoryDisabled" : true}' \
    | sudo tee /etc/chromium-browser/policies/managed/no-history.json

# if we want to install packages, go on

[ "$1" = '-i' ] || exit 0

sudo apt-get update
sudo apt-get -y dist-upgrade

[ -f "$HOME/dotfiles/postinst/pkgs.txt" ] &&
    sudo apt-get -y install $(cat "$HOME/dotfiles/postinst/pkgs.txt")

echo OK
