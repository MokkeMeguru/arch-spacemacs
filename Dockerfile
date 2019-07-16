FROM archlinux/base

# basic settings for archlinux
RUN pacman --noconfirm -Sy pacman-contrib \
  && cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup \
  && rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist \
  && echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf \
  && pacman -Syyu --noconfirm \
  base base-devel git openssh wget which emacs gtk2 python3 noto-fonts-cjk \
  rustup clojure \
###
### RUN   sed -i "s/PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
###
  && echo -e "en_US.UTF-8 UTF-8\nja_JP.UTF-8 UTF-8" > /etc/locale.gen && locale-gen \
  && ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && useradd -m -r -s /bin/bash emacs && passwd -d emacs \
  && echo "emacs ALL=(ALL) ALL" > /etc/sudoers.d/emacs \
  && mkdir /home/emacs/works \
  && chown -R emacs:emacs /home/emacs

# switch user
USER emacs

# installation for yay and mozc
WORKDIR "/home/emacs/works"

RUN rustup default stable \
  && rustup component add rust-src \
  && cargo install racer rustfmt

RUN git clone https://aur.archlinux.org/yay.git
RUN git clone https://aur.archlinux.org/mozc.git
WORKDIR "/home/emacs/works/yay"
RUN makepkg  --noconfirm -si \
  && yay --afterclean --removemake --save
WORKDIR "/home/emacs/works/mozc"
RUN sed -ie "s/#_emacs_mozc=\"yes\"/_emacs_mozc=\"yes\"/" PKGBUILD \
  && sed -ie "s/_ibus_mozc=\"yes\"/#_ibus_mozc=\"yes\"/" PKGBUILD \
  && sed -ie "s/'ibus>=1.4.1'\ //" PKGBUILD \
  && makepkg --noconfirm -si

COPY docker-entrypoint.sh /home/emacs/works
RUN sudo chmod +x /home/emacs/works/docker-entrypoint.sh \
  && mkdir /home/emacs/mnt

# settings for spacemacs
WORKDIR "/home/emacs"
RUN git clone -b develop https://github.com/syl20bnr/spacemacs /home/emacs/.emacs.d
COPY .spacemacs /home/emacs/.spacemacs
RUN sudo chown emacs /home/emacs/.spacemacs
RUN emacs --daemon
# &&  emacsclient -e "(configuration-layer/update-packages t)" \
# &&  emacsclient -e "(dotspacemacs/sync-configuration-layers)"

WORKDIR "/home/emacs"
# ENTRYPOINT ["/home/emacs/works/docker-entrypoint.sh"]
