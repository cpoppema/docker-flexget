FROM lsiobase/alpine:3.18

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"

RUN apk add \
    bash \
    libxml2-dev \
    libxslt-dev \
    python3 \
    python3-dev \
    py3-libtorrent-rasterbar \
    py3-lxml && \
 echo "**** install build packages ****" && \
 apk add --no-cache \
    g++ \
    gcc \
    linux-headers \
    openssl-dev && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
    curl \
    openssl \
    wget && \
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
    paramiko \
    psutil \
    pyopenssl \
    requests \
    urllib3 && \
 echo "**** clean up ****" && \
 rm -rf \
    /root/.cache \
    /tmp/* \
    /build \
    /root/packages

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
