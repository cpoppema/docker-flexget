##############################################################################
# Source: https://github.com/linuxserver/docker-baseimage-alpine-python3/blob/master/Dockerfile
# Simply using it as a baseimage fails:
# - installing g++ fails (baseimage already installs it and purges it afterwards, so let's keep it)
# - installing python 3.7.3 because that is what py3-libtorrent-rasterbar requires (doesn't work with 3.6.8)
FROM lsiobase/alpine:3.9

# Add edge/testing repositories.
RUN printf "\
@edge http://nl.alpinelinux.org/alpine/edge/main\n\
@testing http://nl.alpinelinux.org/alpine/edge/testing\n\
@community http://nl.alpinelinux.org/alpine/edge/community\n\
" >> /etc/apk/repositories

RUN apk add \
    python3@edge \
    python3-dev@edge \
    py3-lxml@edge \
    boost-python3@edge  \
    bash@edge

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
 echo "**** clean up ****" && \
 rm -rf \
    /root/.cache \
    /tmp/*

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

# Ports and volumes.
EXPOSE 5050/tcp
VOLUME /config
