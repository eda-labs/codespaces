#!/bin/bash
source .devcontainer/utils.sh

cd $EDA_PLAYGROUND_DIR

ensure-docker-is-ready

# start the kind cluster
make kind

# get token
encoded=$(grep 'GH_PKG_TOKEN ?=' "Makefile" | sed 's/.*?= *//')
prefix=$(printf '%s' 'Z2hwCg==' | base64 -d)
suffix=$(printf '%s' "$encoded" | base64 -d | cut -c 4-)
TOKEN="${prefix}${suffix}"

# preload images into kind cluster from the EDA core list
docker cp /home/vscode/.images.txt eda-demo-control-plane:/opt/images.txt
docker exec eda-demo-control-plane sh -c "cat /opt/images.txt | xargs -P $(nproc) -I {} crictl pull --creds $TOKEN {}"

make -f Makefile -f $TRY_EDA_OVERRIDES_FILE try-eda KPT_SETTERS_FILE=$TRY_EDA_KPT_SETTERS_FILE