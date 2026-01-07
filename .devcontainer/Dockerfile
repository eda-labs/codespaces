# ghcr.io/eda-labs/eda-devcontainer
FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && apt-get install -y \
    make \
    curl \
    jq \
    btop \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 scripts/ /usr/local/bin/.

RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash