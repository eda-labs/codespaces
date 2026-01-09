#!/bin/bash
source .devcontainer/utils.sh

# Restore custom .zshrc after devcontainer features may have overwritten it
cp /home/vscode/.zshrc.custom /home/vscode/.zshrc 2>/dev/null || true

cd $EDA_PLAYGROUND_DIR

ensure-docker-is-ready

make try-eda NO_KIND=yes NO_LB=yes KPT_SETTERS_FILE=/eda-codespaces/codespaces-4vcpu-kpt-setters.yaml