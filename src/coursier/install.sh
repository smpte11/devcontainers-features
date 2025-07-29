#!/bin/sh
set -e

# Options passed from devcontainer-feature.json
VERSION="${VERSION:-"latest"}"

# Load common-utils to use 'check_packages'
. /usr/local/share/common-utils/main.sh

# curl, gzip, and ca-certificates are required
check_packages curl gzip ca-certificates

echo "Activating feature 'coursier' version ${VERSION}"

# Determine architecture for coursier launchers
ARCHITECTURE="$(uname -m)"
case ${ARCHITECTURE} in
    x86_64) CS_ARCH="x86_64-pc-linux";;
    aarch64 | arm64) CS_ARCH="aarch64-pc-linux";;
    *)
        echo "(!) Architecture ${ARCHITECTURE} not supported."
        exit 1
        ;;
esac

# Construct download URL for the native launcher
if [ "${VERSION}" = "latest" ]; then
    DOWNLOAD_URL="https://github.com/coursier/launchers/raw/master/cs-${CS_ARCH}.gz"
else
    # Add 'v' prefix to version if it doesn't exist for release tags
    if ! echo "${VERSION}" | grep -q "^v"; then
        VERSION="v${VERSION}"
    fi
    DOWNLOAD_URL="https://github.com/coursier/coursier/releases/download/${VERSION}/cs-${CS_ARCH}.gz"
fi

echo "Downloading Coursier launcher from ${DOWNLOAD_URL}"

# Download, decompress, and install the 'cs' launcher
curl -sSL --fail "${DOWNLOAD_URL}" | gzip -d > /usr/local/bin/cs
chmod +x /usr/local/bin/cs

# Run `cs setup` to install the Scala development environment.
# This installs a JVM if needed, and tools like scala, scalac, and sbt.
# It also updates the user's profile files to add the coursier bin directory to the PATH.
# We execute this as the container user to ensure the environment is set up for them.
USERNAME="${_CONTAINER_USER:-"root"}"

if [ "${USERNAME}" = "root" ]; then
    cs setup --yes
else
    # The user might not exist yet, so we need to be careful.
    # However, by the time this script runs, the user should have been created.
    su - "${USERNAME}" -c "cs setup --yes"
fi

echo "Coursier feature installed successfully."
