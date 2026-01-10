#!/bin/bash
source .devcontainer/utils.sh

cd $EDA_PLAYGROUND_DIR

ensure-docker-is-ready

# Run make with 240s inactivity timeout, retry up to 3 times
run-with-inactivity-timeout 240 3 make try-eda NO_KIND=yes NO_LB=yes KPT_SETTERS_FILE=/eda-codespaces/codespaces-4vcpu-kpt-setters.yaml