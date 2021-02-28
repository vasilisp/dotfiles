#!/bin/sh

set -e

UNITS_PATH="$HOME/.config/systemd/user"

# preconditions
[ -d "$UNITS_PATH" ]
which systemctl

# ssh-agent (simpler unit than the default)

tee "$UNITS_PATH/ssh-agent.service" <<EOF
[Unit]
Description=OpenSSH Agent

[Service]
Type=simple
ExecStart=/usr/bin/ssh-agent -D -a %t/openssh_agent

[Install]
WantedBy=default.target
EOF

systemctl --user enable ssh-agent

tee -a "$HOME/.profile_local" <<EOF
SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/openssh_agent"
export SSH_AUTH_SOCK
EOF

# emacs: only override SSH_AUTH_SOCK

which emacs || exit 0

tee "$UNITS_PATH/emacs.service.d/override.conf" <<EOF
[Service]
Environment=SSH_AUTH_SOCK=%t/openssh_agent
EOF

systemctl --user enable emacs
