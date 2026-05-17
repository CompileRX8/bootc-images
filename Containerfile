FROM quay.io/fedora/fedora-sway-atomic:44-x86_64

RUN microdnf install -y \
    arm-image-installer \
    bcvk \
    coreos-installer \
    fontawesome-fonts-all \
    gdisk \
    git \
    lightdm \
    neovim \
    openssl \
    rustup \
    screen \
    terminus-fonts-console \
    tio \
    yq \
    zsh \
&& \
    dnf clean all

# -- Finalize container setup --
RUN bootc container lint

