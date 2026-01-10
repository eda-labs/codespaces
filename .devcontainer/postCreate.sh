#!/bin/bash
source .devcontainer/utils.sh

cd $EDA_PLAYGROUND_DIR

ensure-docker-is-ready

# Run make with 30s inactivity timeout, retry up to 5 times
run-with-inactivity-timeout 60 5 make try-eda NO_KIND=yes NO_LB=yes KPT_SETTERS_FILE=/eda-codespaces/codespaces-4vcpu-kpt-setters.yaml