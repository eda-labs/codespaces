#!/bin/bash
source .devcontainer/utils.sh

cd $EDA_PLAYGROUND_DIR

ensure-docker-is-ready

make -f Makefile -f $TRY_EDA_OVERRIDES_FILE_PATH try-eda