#!/bin/sh

set -e

FILES='bashrc profile shrc_common tmux.conf emacs'

[ "$1" = '-x' ] &&
    FILES="$FILES Xresources xinitrc config/openbox/rc.xml config/gtk-3.0/settings.ini"

for FILE in $FILES; do
    [ -f "$HOME/dotfiles/dot/$FILE" ] || continue
    rm -f "$HOME/.$FILE"
    mkdir -p "$(dirname "$HOME/.$FILE")"
    ln -s "$HOME/dotfiles/dot/$FILE" "$HOME/.$FILE"
done
