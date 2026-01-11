#!/bin/bash
source .devcontainer/utils.sh

echo "System has $(nproc) CPUs"
free -m

sudo sysctl -w fs.inotify.max_user_watches=1048576
sudo sysctl -w fs.inotify.max_user_instances=512

ensure-docker-is-ready

k3d cluster create eda-demo \
    --image rancher/k3s:v1.34.1-k3s1 \
    --k3s-arg "--disable=traefik@server:*" \
    --volume "$HOME/.images.txt:/opt/images.txt@server:*" \
    --port "9444:9444"
