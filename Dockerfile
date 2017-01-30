FROM phusion/baseimage:0.9.19
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh
ENV DEBIAN_FRONTEND noninteractive
ENV TERM screen

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install the latest available package.
RUN apt-get update -q && \
    apt-get install -qy python2.7 python-pip
RUN pip install -U pip setuptools \
    flexget transmissionrpc

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add service files.
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run
RUN chmod -v +x /etc/my_init.d/*.sh

EXPOSE 5050/tcp

VOLUME /config

# Add user.
RUN useradd -u 911 -U -s /bin/false abc
RUN usermod -G users abc
