#!/bin/sh
set -e

# Install dependencies
if ! type apt-get >/dev/null 2>&1; then
    echo "This feature requires apt-get to be available."
    exit 1
fi
apt-get update
apt-get install -y --no-install-recommends curl gzip ca-certificates

# Determine architecture
ARCHITECTURE="$(uname -m)"
case ${ARCHITECTURE} in
x86_64) CS_ARCH="x86_64-pc-linux" ;;
aarch64 | arm64) CS_ARCH="aarch64-pc-linux" ;;
*)
    echo "(!) Architecture ${ARCHITECTURE} not supported."
    exit 1
    ;;
esac

# Download and install coursier
DOWNLOAD_URL="https://github.com/coursier/launchers/raw/master/cs-${CS_ARCH}.gz"
echo "Downloading Coursier launcher from ${DOWNLOAD_URL}"
curl -sSL --fail "${DOWNLOAD_URL}" | gzip -d >cs
chmod +x cs

# Run setup
./cs setup --yes

rm -rf ./cs

. ~/.profile

echo "$PATH"

whoami
