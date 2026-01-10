#!/bin/bash
source .devcontainer/utils.sh

cd $EDA_PLAYGROUND_DIR

ensure-docker-is-ready

docker exec k3d-eda-demo-server-0 sh -c "cat /opt/images.txt | xargs -P $NUM_CONCURRENT_IMG_PREPULLS -I {} crictl pull --creds $TOKEN {}"

make -f Makefile -f /workspaces/codespaces/.devcontainer/overrides.mk try-eda NO_KIND=yes NO_LB=yes KPT_SETTERS_FILE=$TRY_EDA_KPT_SETTERS_FILE