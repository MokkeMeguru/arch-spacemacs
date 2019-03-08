#!/bin/bash
if [ $# -ne 2 ]; then
    echo -e "Please input \nyour ip-addr:port for display (see. your MobaXterm)\nyour ssh folder (ex. /c/Users/<yourname>/.ssh)" 1>&2
    exit 1
fi

docker run -e DISPLAY=$1 -v $2:/tmp/.ssh -v /:/home/emacs/mnt -it --rm arch-spacemacs
