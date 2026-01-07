#!/bin/bash
source .devcontainer/utils.sh

echo "System has $(nproc) CPUs"
free -m

sudo sysctl -w fs.inotify.max_user_watches=1048576
sudo sysctl -w fs.inotify.max_user_instances=512

git clone "https://github.com/$EDA_PLAYGROUND_REPO" $EDA_PLAYGROUND_DIR

curl -o /tmp/bundle.yaml "https://raw.githubusercontent.com/nokia-eda/edaadm/refs/heads/main/bundles/eda-bundle-core-$EDA_VERSION.yaml"

cd $EDA_PLAYGROUND_DIR
make download-tools

echo "export PATH=$PATH:$EDA_PLAYGROUND_DIR/tools" >> $HOME/.zshrc


$EDA_PLAYGROUND_DIR/tools/yq '.assets.registries[] | .name as $reg | .images[] | .name as $img | .tags[] | $reg + "/" + $img + ":" + .' /tmp/bundle.yaml > $HOME/.images.txt
TOKEN=$($EDA_PLAYGROUND_DIR/tools/yq -o=json '.assets.registries[].auth' /tmp/bundle.yaml | jq -r '(reduce range(.extraEncodeCount + 1) as $_ (.username; @base64d)) + ":" + (reduce range(.extraEncodeCount + 1) as $_ (.password; @base64d))')

ensure-docker-is-ready

k3d cluster create eda-demo \
    --k3s-arg "--disable=traefik@server:*" \
    --k3s-arg "--disable=servicelb@server:*" \
    --volume "$HOME/.images.txt:/opt/images.txt@server:*" \
    --no-lb

docker exec -d k3d-eda-demo-server-0 sh -c "cat /opt/images.txt | xargs -P 4 -I {} crictl pull --creds $TOKEN {}"