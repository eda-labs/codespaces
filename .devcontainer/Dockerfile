# ghcr.io/eda-labs/eda-devcontainer
FROM public.ecr.aws/docker/library/debian:bookworm-slim

ARG EDA_VERSION=25.12.1
ARG EDA_PLAYGROUND_REPO=kaelemc/playground
ARG EDA_PLAYGROUND_DIR=/home/vscode/.playground

ENV EDA_VERSION=${EDA_VERSION//./-}
ENV EDA_PLAYGROUND_REPO=$EDA_PLAYGROUND_REPO
ENV EDA_PLAYGROUND_DIR=$EDA_PLAYGROUND_DIR

RUN apt-get update && apt-get install --no-install-recommends -y \
    make \
    git \
    ca-certificates \
    curl \
    jq \
    btop \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/zsh vscode && \
    usermod -aG sudo vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vscode && \
    chmod 0440 /etc/sudoers.d/vscode

COPY --chmod=755 scripts/ /usr/local/bin/.

RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

RUN echo "export PATH=$PATH:$EDA_PLAYGROUND_DIR/tools" >> /etc/profile

USER vscode

RUN git clone --depth 1 "https://github.com/$EDA_PLAYGROUND_REPO" $EDA_PLAYGROUND_DIR && cd $EDA_PLAYGROUND_DIR && make download-tools

RUN curl -o $HOME/.bundle.yaml "https://raw.githubusercontent.com/nokia-eda/edaadm/refs/heads/main/bundles/eda-bundle-core-$EDA_VERSION.yaml" && \
    $EDA_PLAYGROUND_DIR/tools/yq '.assets.registries[] | .name as $reg | .images[] | .name as $img | .tags[] | $reg + "/" + $img + ":" + .' $HOME/.bundle.yaml > $HOME/.images.txt