#!/bin/bash
source .devcontainer/utils.sh

echo "System has $(nproc) CPUs"
free -m

ensure-docker-is-ready

# start the k3d cluster
k3d cluster create eda-demo \
    --image rancher/k3s:v1.34.1-k3s1 \
    --k3s-arg "--disable=traefik@server:*" \
    --volume "$HOME/.images.txt:/opt/images.txt@server:*" \
    --port "9443:443" \
    --port "9400-9410:9400-9410"