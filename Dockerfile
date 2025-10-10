FROM archlinux/archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
      # Download source code
      git \
      # Required by makepkg itself
      sudo fakeroot debugedit binutils

RUN useradd -m -u 1001 -s /bin/zsh builder && \
    echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir /build && chown builder:builder /build && \
    mkdir /target && chown builder:builder /target

USER builder

WORKDIR /build

RUN git clone https://aur.archlinux.org/paru-bin.git && \
    cd paru-bin && \
    makepkg -si --noconfirm

RUN paru -Sy pgadmin4 --noconfirm

RUN mv /home/builder/.cache/paru/clone/pgadmin4-server/*.pkg.tar.zst /target/ && \
    mv /home/builder/.cache/paru/clone/pgadmin4-desktop/*.pkg.tar.zst /target/ && \
    mv /home/builder/.cache/paru/clone/pgadmin4-web/*.pkg.tar.zst /target/ && \
    mv /home/builder/.cache/paru/clone/pgadmin4/*.pkg.tar.zst /target/

ENTRYPOINT ["bash"]
