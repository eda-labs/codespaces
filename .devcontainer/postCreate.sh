#!/bin/bash
source .devcontainer/utils.sh

cd $EDA_PLAYGROUND_DIR

ensure-docker-is-ready

# Run make with 90s inactivity timeout, retry up to 5 times
run-with-inactivity-timeout 90 5 make try-eda NO_KIND=yes NO_LB=yes KPT_SETTERS_FILE=/eda-codespaces/codespaces-4vcpu-kpt-setters.yaml