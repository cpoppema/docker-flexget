##############################################################################
# Source: https://github.com/linuxserver/docker-baseimage-alpine-python3/blob/master/Dockerfile
# Simply using it as a baseimage fails:
# - installing g++ fails (baseimage already installs it and purges it afterwards, so let's keep it)
# - installing python 3.7.3 because that is what py3-libtorrent-rasterbar requires (doesn't work with 3.6.8)
FROM lsiobase/alpine:3.10

RUN apk add \
    libxml2-dev \
    libxslt-dev \
    python3 \
    python3-dev \
    py3-lxml \
    boost-python3  \
    bash && \
    echo "**** install alpine sdk so that we can build libtorrent python bindings (for various plugin) ****" && \
    apk add alpine-sdk && \
    abuild-keygen -ian && \
    usermod -aG abuild root

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache \
    autoconf \
    automake \
    freetype-dev \
    g++ \
    gcc \
    jpeg-dev \
    lcms2-dev \
    libffi-dev \
    libpng-dev \
    libwebp-dev \
    linux-headers \
    make \
    openjpeg-dev \
    openssl-dev \
    tiff-dev \
    zlib-dev && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
    curl \
    freetype \
    git \
    lcms2 \
    libjpeg-turbo \
    libwebp \
    openjpeg \
    openssl \
    p7zip \
    tar \
    tiff \
    unrar \
    unzip \
    vnstat \
    wget \
    xz \
    zlib && \
 echo "**** use ensure to check for pip and link /usr/bin/pip3 to /usr/bin/pip ****" && \
 python3 -m ensurepip && \
 rm -r /usr/lib/python*/ensurepip && \
 if \
    [ ! -e /usr/bin/pip ]; then \
    ln -s /usr/bin/pip3 /usr/bin/pip ; fi && \
 echo "**** install pip packages ****" && \
 pip install --no-cache-dir -U \
    pip \
    setuptools && \
 pip install -U \
    configparser \
    ndg-httpsclient \
    notify \
    paramiko \
    pillow \
    psutil \
    pyopenssl \
    requests \
    setuptools \
    urllib3 \
    virtualenv && \
 echo "**** build libtorrent-rasterbar, this takes a bit ****" && \
 mkdir -p /build/py3-libtorrent-rasterbar && \
 cd /build/py3-libtorrent-rasterbar && \
 wget https://git.alpinelinux.org/aports/plain/testing/libtorrent-rasterbar/APKBUILD && \
 abuild -F checksum && abuild -Fr && \
 apk add --repository /root/packages/build py3-libtorrent-rasterbar && \
 echo "**** clean up ****" && \
 rm -rf \
    /root/.cache \
    /tmp/* \
    /build \
    /root/packages

##############################################################################
# Here starts the usual changes compared to baseimage.

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"

# Set python to use utf-8 rather than ascii.
# Also, for python3: https://bugs.python.org/issue19846
ENV LANG C.UTF-8

# Copy local files.
COPY etc/ /etc
RUN chmod -v +x \
    /etc/cont-init.d/*  \
    /etc/services.d/*/run
COPY requirements.txt /

# Ports and volumes.
EXPOSE 5050/tcp
VOLUME /config

# Flexget looks for config.yml automatically inside:
# /root/.flexget, /root/.config/flexget
# Since the uid/gid for user abc can be changed on the fly, set 777.
RUN CONFIG_SYMLINK_DIR=/root \
    && ln -s /config "$CONFIG_SYMLINK_DIR/.flexget" \
    && chmod 777 "$CONFIG_SYMLINK_DIR/" \
    && chmod 777 "$CONFIG_SYMLINK_DIR/.flexget/"
