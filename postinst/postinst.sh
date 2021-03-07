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
[ -d /etc/systemd/network ]
[ -d /etc/polkit-1/localauthority ]

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

# ubuntu firewall

sudo ufw enable

# systemd-networkd

sudo tee "/etc/systemd/network/$NET.network" <<EOF
[Match]
Name=$NET
[Network]
DHCP=yes
EOF

# wpa_supplicant

[ -d /etc/wpa_supplicant ] || sudo mkdir /etc/wpa_supplicant

sudo tee "/etc/wpa_supplicant/wpa_supplicant-$NET.conf" <<EOF
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=netdev
update_config=1
EOF

sudo chmod go-rwx "/etc/wpa_supplicant/wpa_supplicant-$NET.conf"

# control brightness without bloat

sudo tee /lib/udev/rules.d/90-brightness.rules <<EOF
ACTION=="add", SUBSYSTEM=="backlight", \\
  RUN+="/bin/chown root:video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", \\
  RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF

sudo usermod -a -G video "$(whoami)"

# disable unneeded services

[ -d /etc/cloud ] &&
    sudo touch /etc/cloud/cloud-init.disabled

sudo systemctl disable accounts-daemon atd multipathd packagekit

[ -f /etc/netplan/00-installer-config.yaml ] &&
    sudo rm /etc/netplan/00-installer-config.yaml

# use machinectl without a password

sudo tee /etc/polkit-1/localauthority/50-local.d/machinectl.pkla <<EOF
[machinectl permissions]
Identity=unix-user:$(whoami)
Action=org.freedesktop.machine1.shell;org.freedesktop.machine1.login
ResultActive=yes
EOF

sudo chmod go-rwx /etc/polkit-1/localauthority/50-local.d/machinectl.pkla

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

# enable wpa_supplicant now that it exists

sudo systemctl enable "wpa_supplicant@$NET"
sudo usermod -a -G netdev "$(whoami)"

# systemd user services

[ -f "$HOME/dotfiles/postinst/postinst-systemd-user.sh" ] &&
    sh "$HOME/dotfiles/postinst/postinst-systemd-user.sh"

# install snaps too

sudo snap refresh

if [ -f "$HOME/dotfiles/postinst/snaps.txt" ]; then
    sudo snap install $(cat "$HOME/dotfiles/postinst/snaps.txt") || true
fi

echo OK
