#!/bin/bash
source .devcontainer/utils.sh

echo "System has $(nproc) CPUs"
free -m

sudo sysctl -w fs.inotify.max_user_watches=1048576
sudo sysctl -w fs.inotify.max_user_instances=512
# xyz
TOKEN=$($EDA_PLAYGROUND_DIR/tools/yq -o=json '.assets.registries[].auth' $HOME/.bundle.yaml | jq -r '(reduce range(.extraEncodeCount + 1) as $_ (.username; @base64d)) + ":" + (reduce range(.extraEncodeCount + 1) as $_ (.password; @base64d))')

ensure-docker-is-ready

k3d cluster create eda-demo \
    --image rancher/k3s:v1.34.1-k3s1 \
    --k3s-arg "--disable=traefik@server:*" \
    --k3s-arg "--disable=servicelb@server:*" \
    --volume "$HOME/.images.txt:/opt/images.txt@server:*" \
    --no-lb

docker exec k3d-eda-demo-server-0 sh -c "cat /opt/images.txt | xargs -P $NUM_CONCURRENT_IMG_PREPULLS -I {} crictl pull --creds $TOKEN {}"