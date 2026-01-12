#!/bin/bash
source .devcontainer/utils.sh

cd $EDA_PLAYGROUND_DIR

ensure-docker-is-ready

# start the kind cluster
make kind

# preload images into kind cluster from the EDA core list
TOKEN=$($EDA_PLAYGROUND_DIR/tools/yq -o=json '.assets.registries[].auth' $HOME/.bundle.yaml | jq -r '(reduce range(.extraEncodeCount + 1) as $_ (.username; @base64d)) + ":" + (reduce range(.extraEncodeCount + 1) as $_ (.password; @base64d))')
docker cp /home/vscode/images.txt eda-demo-control-plane:/opt/images.txt
docker exec eda-demo-control-plane sh -c "cat /opt/images.txt | xargs -P $(nproc) -I {} crictl pull --creds $TOKEN {}"

make -f Makefile -f $TRY_EDA_OVERRIDES_FILE try-eda NO_KIND=yes NO_LB=yes KPT_SETTERS_FILE=$TRY_EDA_KPT_SETTERS_FILE