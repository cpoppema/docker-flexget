#!/bin/bash

if [[ "$TORRENT_PLUGIN" == *"deluge"* ]]; then
    PACKAGES="deluge-common"

    apt-get update -q \
     && apt-get install -qy \
        $PACKAGES
fi
