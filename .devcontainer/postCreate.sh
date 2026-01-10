#!/bin/bash
source .devcontainer/utils.sh

cd $EDA_PLAYGROUND_DIR

ensure-docker-is-ready

make -f Makefile -f /workspaces/codespaces/.devcontainer/overrides.mk try-eda NO_KIND=yes NO_LB=yes KPT_SETTERS_FILE=$TRY_EDA_KPT_SETTERS_FILE