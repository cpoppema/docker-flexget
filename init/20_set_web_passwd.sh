#!/bin/bash

# Set the password if there is no lock file. This lock file is created when
# setting the password.
#
# This lock file prevents an accidental reset of the password, in case this
# container is recreated or restarted, after manually changing the password.
#

if [ ! -f /config/.password-lock ]; then
    if [ ! -z "$WEB_PASSWD" ]; then
        touch /config/.password-lock && chown abc:abc /config/.password-lock
        /usr/local/bin/flexget -c /config/config.yml --loglevel debug web passwd "$WEB_PASSWD"
    fi
fi
