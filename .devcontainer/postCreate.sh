#!/bin/bash
source .devcontainer/utils.sh

cd $EDA_PLAYGROUND_DIR

# get token
encoded=$(grep 'GH_PKG_TOKEN ?=' "Makefile" | sed 's/.*?= *//')
prefix=$(printf '%s' 'Z2hwCg==' | base64 -d)
suffix=$(printf '%s' "$encoded" | base64 -d | cut -c 4- | tr -d '\n')
TOKEN="${prefix}${suffix}"

# preload images into the cluster from the EDA core list
PARALLEL_JOBS=$(($(nproc) - 1))
docker exec k3d-eda-demo-server-0 sh -c "cat /opt/images.txt | xargs -P $PARALLEL_JOBS -I {} crictl pull --creds nokia-eda-bot:$TOKEN {}"

make -f Makefile -f $TRY_EDA_OVERRIDES_FILE try-eda NO_KIND=yes NO_LB=yes KPT_SETTERS_FILE=$TRY_EDA_KPT_SETTERS_FILE
