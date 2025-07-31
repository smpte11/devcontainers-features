#!/bin/sh
set -e

# Install dependencies
if ! type apt-get > /dev/null 2>&1; then
    echo "This feature requires apt-get to be available."
    exit 1
fi
apt-get update
apt-get install -y --no-install-recommends curl gzip ca-certificates sudo

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

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
cleanup() {
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

# Download the coursier launcher to a temporary file
DOWNLOAD_URL="https://github.com/coursier/launchers/raw/master/cs-${CS_ARCH}.gz"
echo "Downloading Coursier launcher from ${DOWNLOAD_URL}"
curl -sSL --fail "${DOWNLOAD_URL}" | gzip -d > "${TMP_DIR}/cs"
chmod +x "${TMP_DIR}/cs"

# Run setup as the container user
USERNAME="${_CONTAINER_USER:-"root"}"
if [ "${USERNAME}" = "root" ]; then
    "${TMP_DIR}/cs" setup --yes
    INSTALL_DIR=$(cs install-dir)
else
    # The user might not exist yet, so we need to be careful.
    # However, by the time this script runs, the user should have been created.
    su - "${USERNAME}" -c "'${TMP_DIR}/cs' setup --yes"
    INSTALL_DIR=$(su - "${USERNAME}" -c "cs install-dir")
fi

# Add the installation directory to the PATH for all users
echo "export PATH=\$PATH:${INSTALL_DIR}" > /etc/profile.d/coursier.sh
chmod +x /etc/profile.d/coursier.sh

echo "Coursier feature installed successfully."
