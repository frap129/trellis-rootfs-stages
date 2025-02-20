FROM docker.io/cachyos/cachyos:latest AS v3

RUN pacman-key --init
RUN pacman-key --populate
RUN pacman -Sy --noconfirm \
  arch-install-scripts \
  base-devel \
  sudo \
  git \
  grub \
  ostree \
  rsync \
  sbctl

# This allows using this container to make a deployment.
RUN ln -s sysroot/ostree /ostree

# This allows using pacstrap -N in a rootless container.
RUN echo 'root:1000:5000' > /etc/subuid
RUN echo 'root:1000:5000' > /etc/subgid

# Setup for building AUR packages
RUN sed -i "s/native/x86-64-v3/g" /etc/makepkg.conf && \
  sed -i "s/native/x86-64-v3/g" /etc/makepkg.conf.d/rust.conf
RUN pacman --noconfirm -Syu base-devel git sudo
RUN useradd -m builder
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/builder
USER builder
USER root
RUN mkdir /aur
COPY /rootfs/usr/bin/build-aur.sh /usr/bin/build-aur

FROM v3 AS v4
RUN sed -i "s/x86-64-v3/x86-64-v4/g" /etc/makepkg.conf && \
  sed -i "s/x86-64-v3/x86-64-v4/g" /etc/makepkg.conf.d/rust.conf

