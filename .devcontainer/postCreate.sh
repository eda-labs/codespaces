#!/bin/bash
source .devcontainer/utils.sh

cd $EDA_PLAYGROUND_DIR

ensure-docker-is-ready

make try-eda NO_KIND=yes NO_LB=yes KPT_SETTERS_FILE=/tmp/codespaces-4vcpu-kpt-setters.yaml