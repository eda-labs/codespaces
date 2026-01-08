# ghcr.io/eda-labs/eda-devcontainer
FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG EDA_VERSION=25.12.1
ARG EDA_PLAYGROUND_REPO=kaelemc/playground
ARG EDA_PLAYGROUND_DIR=/home/vscode/.playground

ENV EDA_VERSION=${EDA_VERSION//./-}
ENV EDA_PLAYGROUND_REPO=$EDA_PLAYGROUND_REPO
ENV EDA_PLAYGROUND_DIR=$EDA_PLAYGROUND_DIR

RUN apt-get update && apt-get install -y \
    make \
    curl \
    jq \
    btop \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 scripts/ /usr/local/bin/.

RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

RUN echo "export PATH=$PATH:$EDA_PLAYGROUND_DIR/tools" >> /etc/profile

USER vscode

RUN git clone "https://github.com/$EDA_PLAYGROUND_REPO" $EDA_PLAYGROUND_DIR && cd $EDA_PLAYGROUND_DIR && make download-tools

RUN curl -o $HOME/.bundle.yaml "https://raw.githubusercontent.com/nokia-eda/edaadm/refs/heads/main/bundles/eda-bundle-core-$EDA_VERSION.yaml" && \
    $EDA_PLAYGROUND_DIR/tools/yq '.assets.registries[] | .name as $reg | .images[] | .name as $img | .tags[] | $reg + "/" + $img + ":" + .' $HOME/.bundle.yaml > $HOME/.images.txt