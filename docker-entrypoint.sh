#!/bin/sh
set -e

cp -R /tmp/.ssh /home/emacs/.ssh
chmod 700 /home/emacs/.ssh
chmod 644 /home/emacs/.ssh/id_rsa.pub
chmod 600 /home/emacs/.ssh/id_rsa

exec /bin/bash
