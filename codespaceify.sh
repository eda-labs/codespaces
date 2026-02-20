#!/bin/bash

BASE_URL="https://raw.githubusercontent.com/eda-labs/codespaces/main/.devcontainer"

if git rev-parse --show-toplevel &>/dev/null; then
    TARGET_DIR=$(git rev-parse --show-toplevel)
    REPO_NAME=$(basename "$TARGET_DIR")
    echo "Detected git repository: $REPO_NAME"
else
    TARGET_DIR=$(pwd)
    REPO_NAME=$(basename "$TARGET_DIR")
    echo "Not a git repository, using current directory: $REPO_NAME"
fi

if [[ -d "$TARGET_DIR/.devcontainer" ]]; then
    echo ""
    echo ".devcontainer directory already exists."
    read -p "Overwrite? [y/N]: " confirm < /dev/tty
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

echo ""
echo "Select GitHub Codespace machine type:"
echo ""
echo "  1) 4-core   (4 vCPUs, 16 GB RAM, 32 GB storage)"
echo "  2) 8-core   (8 vCPUs, 32 GB RAM, 64 GB storage)"
# echo "  3) 16-core  (16 vCPUs, 64 GB RAM, 128 GB storage)"
# echo "  4) 32-core  (32 vCPUs, 128 GB RAM, 256 GB storage)"
echo ""

while true; do
    read -p "Enter choice [1-2] (default: 1): " choice < /dev/tty
    choice=${choice:-1}

    case $choice in
        1) CPUS=4;  MEMORY="16gb";  STORAGE="32gb";  break ;;
        2) CPUS=8;  MEMORY="32gb";  STORAGE="64gb";  break ;;
        # 3) CPUS=16; MEMORY="64gb";  STORAGE="128gb"; break ;;
        # 4) CPUS=32; MEMORY="128gb"; STORAGE="256gb"; break ;;
        *) echo "Invalid choice." ;;
    esac
done

echo ""
echo "Selected: $CPUS vCPUs, $MEMORY RAM, $STORAGE storage"
echo ""

DEST="$TARGET_DIR/.devcontainer"
mkdir -p "$DEST"

# Runtime files — fetch directly from GitHub
RUNTIME_FILES=(
    initCommand.sh
    onCreate.sh
    postCreate.sh
    postAttach.sh
    utils.sh
    overrides.mk
)

echo "Fetching runtime files from eda-labs/codespaces..."
for f in "${RUNTIME_FILES[@]}"; do
    echo "  $f"
    curl -fsSL "${BASE_URL}/${f}" -o "${DEST}/${f}"
done

chmod +x "$DEST"/*.sh

# Fetch devcontainer.json from source, then patch dynamic values
echo "  devcontainer.json"
curl -fsSL "${BASE_URL}/devcontainer.json" -o "${DEST}/devcontainer.json"

# Patch name to include lab repo name
sed -i "s|\"name\": \".*\"|\"name\": \"Nokia EDA - ${REPO_NAME}\"|" "$DEST/devcontainer.json"

# Patch hostRequirements to match selected machine type
sed -i "s|\"cpus\": [0-9]*|\"cpus\": ${CPUS}|" "$DEST/devcontainer.json"
sed -i "s|\"memory\": \"[^\"]*\"|\"memory\": \"${MEMORY}\"|" "$DEST/devcontainer.json"
sed -i "s|\"storage\": \"[^\"]*\"|\"storage\": \"${STORAGE}\"|" "$DEST/devcontainer.json"

echo ""
echo "Files created in .devcontainer/:"
echo "  ├── devcontainer.json"
echo "  ├── initCommand.sh"
echo "  ├── onCreate.sh"
echo "  ├── postCreate.sh"
echo "  ├── postAttach.sh"
echo "  ├── utils.sh"
echo "  └── overrides.mk"

# README badge
README_FILE="$TARGET_DIR/README.md"

if [[ -f "$README_FILE" ]]; then
    # Detect org/repo from git remote
    GH_REPO=""
    REMOTE_URL=$(git -C "$TARGET_DIR" remote get-url origin 2>/dev/null || true)
    if [[ -n "$REMOTE_URL" ]]; then
        GH_REPO=$(echo "$REMOTE_URL" | sed -E 's|.*github\.com[:/]||; s|\.git$||')
    fi

    if [[ -n "$GH_REPO" ]]; then
        echo ""
        read -p "Add Codespaces badges to README.md? [y/N]: " add_badge < /dev/tty
        if [[ ! "$add_badge" =~ ^[Yy]$ ]]; then
            echo "Skipping README badges."
        else

        BADGE_BLOCK="[![Codespaces][codespaces-4vcpu-svg]][codespaces-4vcpu-url] [![Codespaces][codespaces-8vcpu-svg]][codespaces-8vcpu-url]

[codespaces-4vcpu-svg]: https://gitlab.com/-/project/7617705/uploads/3f69f403e1371b3b578ee930df8930e8/codespaces-btn-4vcpu-export.svg
[codespaces-4vcpu-url]: https://codespaces.new/${GH_REPO}
[codespaces-8vcpu-svg]: https://gitlab.com/-/project/7617705/uploads/81362429e362ce7c5750bc51d23a4905/codespaces-btn-8vcpu-export.svg
[codespaces-8vcpu-url]: https://codespaces.new/${GH_REPO}?machine=premiumLinux
"
        # Prepend badges to the top of README
        printf '%s\n' "$BADGE_BLOCK" | cat - "$README_FILE" > "$README_FILE.tmp"
        mv "$README_FILE.tmp" "$README_FILE"

        echo "Added Codespaces badges to top of README.md"
        fi
    else
        echo "Could not detect GitHub remote — skipping README badges"
    fi
fi

echo ""
echo "Done. Codespace ready for $REPO_NAME."
