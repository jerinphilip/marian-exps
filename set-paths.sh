#!/bin/bash
set -x

# Setup env
MARIAN_INSTALLED_DIR=$(realpath ../env)

export PATH="$MARIAN_INSTALLED_DIR/bin:$PATH".
export LD_LIBRARY_PATH="$MARIAN_INSTALLED_DIR/lib:$LD_LIBRARY_PATH".

set +x;
