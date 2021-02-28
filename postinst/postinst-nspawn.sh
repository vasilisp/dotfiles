#!/bin/sh

set -e

[ -f "$HOME/dotfiles/postinst/postinst-dot.sh" ] &&
    sh "$HOME/dotfiles/postinst/postinst-dot.sh" -x

[ -f "$HOME/dotfiles/postinst/postinst-systemd-user.sh" ] &&
    sh "$HOME/dotfiles/postinst/postinst-systemd-user.sh"
