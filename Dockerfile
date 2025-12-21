FROM archlinux/archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
      # Download source code
      git \
      # Required by makepkg itself
      sudo fakeroot debugedit binutils \
      # Build mod_wsgi
      gcc make

RUN useradd -m -u 1001 -s /bin/zsh builder && \
    echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir /build && chown builder:builder /build && \
    mkdir /target && chown builder:builder /target

USER builder

WORKDIR /build

RUN git clone https://aur.archlinux.org/yay-bin.git && \
    cd yay-bin && \
    makepkg -si --noconfirm

RUN yay -Sy pgadmin4 --noconfirm

RUN bash -c 'find /home/builder/.cache/paru/clone/ -name "pgadmin4*.pkg.tar.zst" -type f | while read -r file; do \
        new_name=$(basename "${file}" | sed -E "s/(-[0-9]+\.[0-9]+)-[0-9]+/\1/"); \
        mv "${file}" "/target/${new_name}"; \
    done'

ENTRYPOINT ["bash"]
