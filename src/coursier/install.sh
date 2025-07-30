#!/bin/sh
set -e

# Install dependencies
if ! type apt-get > /dev/null 2>&1; then
    echo "This feature requires apt-get to be available."
    exit 1
fi
apt-get update
apt-get install -y --no-install-recommends curl gzip ca-certificates

# Determine architecture
ARCHITECTURE="$(uname -m)"
case ${ARCHITECTURE} in
    x86_64) CS_ARCH="x86_64-pc-linux";;
    aarch64 | arm64) CS_ARCH="aarch64-pc-linux";;
    *)
        echo "(!) Architecture ${ARCHITECTURE} not supported."
        exit 1
        ;;
esac

# Download and install coursier
DOWNLOAD_URL="https://github.com/coursier/launchers/raw/master/cs-${CS_ARCH}.gz"
echo "Downloading Coursier launcher from ${DOWNLOAD_URL}"
curl -sSL --fail "${DOWNLOAD_URL}" | gzip -d > /usr/local/bin/cs
chmod +x /usr/local/bin/cs

# Run setup
cs setup --yes

# Add the coursier bin to the path for the current and future shells
INSTALL_DIR=$(cs install-dir)
echo "export PATH=\$PATH:${INSTALL_DIR}" >> ~/.bashrc
echo "export PATH=\$PATH:${INSTALL_DIR}" >> ~/.profile
export PATH="$PATH:${INSTALL_DIR}"
