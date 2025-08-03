#!/bin/sh
set -e

# This script installs coursier, the Scala application and artifact manager.
#
# It is designed to work on Microsoft base images, which have a non-root 'vscode' user with sudo access.
# The script will install coursier for this non-root user.
#
# The script will:
# 1. Determine the system architecture.
# 2. Download the appropriate coursier launcher.
# 3. Run 'cs setup' to install coursier and common Scala tools.
# 4. The installation is done for the user specified by _REMOTE_USER.
# 5. Symlinks are created in /usr/local/bin for immediate access to the tools.

# Ensure that the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Check for required utilities and install them if not present
if ! command -v curl >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y curl
fi
if ! command -v gzip >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y gzip
fi
if ! command -v sudo >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y sudo
fi

# Set default values for options
VERSION="${VERSION:-"latest"}"
APPS="${APPS:-"cs,scala-cli,scala,scalac,sbt,sbtn,ammonite,scalafmt"}"

# These following environment variables are passed in by the dev container CLI.
# For more details, see https://containers.dev/implementors/features#user-env-var
USERNAME="${_REMOTE_USER:-"automatic"}"
USER_HOME="${_REMOTE_USER_HOME:-"/root"}"

if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME="$(find /home -type d -printf '%P\n' -maxdepth 0 | xargs)"
    USER_HOME="/home/${USERNAME}"
    if [ ! -d "${USER_HOME}" ]; then
        USERNAME=root
        USER_HOME=/root
    fi
elif [ "${USERNAME}" = "root" ]; then
    USER_HOME="/root"
fi


# The installation directory for coursier applications
INSTALL_DIR="${USER_HOME}/.local/share/coursier"
BIN_DIR="${INSTALL_DIR}/bin"

# Create the installation directory and set ownership
mkdir -p "${BIN_DIR}"
chown -R "${USERNAME}" "${INSTALL_DIR}"
# If the user is not root, also set the group
if [ "${USERNAME}" != "root" ]; then
    chown -R "${USERNAME}:${USERNAME}" "${INSTALL_DIR}"
fi

# Determine architecture
ARCHITECTURE="$(uname -m)"
case ${ARCHITECTURE} in
    x86_64) ARCH="x86_64-pc-linux";;
    aarch64 | arm64) ARCH="aarch64-pc-linux";;
    *)
        echo "unsupported architecture: ${ARCHITECTURE}"
        exit 1
        ;;
esac

# Download coursier launcher
if [ "${VERSION}" = "latest" ]; then
    DOWNLOAD_URL="https://github.com/coursier/launchers/raw/master/cs-${ARCH}.gz"
else
    # The version tag in github is prefixed with 'v'
    DOWNLOAD_URL="https://github.com/coursier/coursier/releases/download/v${VERSION}/cs-${ARCH}.gz"
fi

echo "Downloading coursier from ${DOWNLOAD_URL}"
TMP_DIR="/tmp/coursier-download"
mkdir -p "${TMP_DIR}"
curl -fL "${DOWNLOAD_URL}" | gzip -d > "${TMP_DIR}/cs"
chmod +x "${TMP_DIR}/cs"

# Run setup as the user
echo "Installing coursier for user ${USERNAME}..."
# We use sudo to run the command as the specified user.
# The --user-home option tells cs setup where to find the profile files (.profile, .bash_profile, etc.)
# The --install-dir option specifies where to install the application launchers.
# cs setup will add the BIN_DIR to the user's PATH in their profile files.
sudo -u "${USERNAME}" -H -- sh -c "${TMP_DIR}/cs setup --yes --install-dir '${BIN_DIR}' --user-home '${USER_HOME}' --apps \"${APPS}\""

# Clean up
rm -rf "${TMP_DIR}"

# Add the bin directory to the PATH for all users
echo "export PATH=\$PATH:${BIN_DIR}" > /etc/profile.d/coursier.sh
chmod +x /etc/profile.d/coursier.sh

echo "Coursier feature installation complete."
