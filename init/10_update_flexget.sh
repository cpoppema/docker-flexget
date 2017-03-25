#!/bin/bash

# Pin setuptools to version 32 to avoid a race condition, see:
# https://github.com/pypa/setuptools/issues/951
pip install pip setuptools==32 flexget transmissionrpc -U
