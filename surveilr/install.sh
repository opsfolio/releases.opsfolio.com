#!/bin/bash

# This script will install only Linux, MacOS, and Windows builds

# Detect the platform
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
echo "Detected platform: $PLATFORM"

# Set the BUILD based on the detected platform
case "$PLATFORM" in
    "darwin") BUILD="apple-darwin.zip" ;;
    "linux") BUILD="unknown-linux-musl.tar.gz" ;;
    *"cygwin"*|*"mingw"*|*"msys"*) BUILD="pc-windows-gnu.zip" ;;
    *) echo "Unsupported platform"; exit 1 ;;
esac

# Set the SURVEILR_HOME environment variable to the current directory if not already set
: ${SURVEILR_HOME:=$(pwd)}
echo "Surveilr will be downloaded at: $SURVEILR_HOME"

# Set the repository owner and repository name
REPO_OWNER="opsfolio"
REPO_NAME="releases.opsfolio.com"

# GitHub API URL for the latest release
API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"

# Fetch the latest release tag from GitHub API and construct the download URL
DOWNLOAD_URL=$(curl -s $API_URL | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | xargs -I {} echo "https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/{}/resource-surveillance_{}_x86_64-${BUILD}")
echo "Constructed download URL: $DOWNLOAD_URL"

# Notify about the start of the download and extraction process
echo "Starting download and extraction..."

# Download and extract the binary to the SURVEILR_HOME directory
if [ "$PLATFORM" = "darwin" ]; then
	curl -sL $DOWNLOAD_URL -o temp.zip && unzip -j -q temp.zip -d $SURVEILR_HOME && rm temp.zip
elif [[ "$PLATFORM" == *"cygwin"* || "$PLATFORM" == *"mingw"* || "$PLATFORM" == *"msys"* ]]; then
	curl -sL $DOWNLOAD_URL -o temp.zip && unzip -j -q temp.zip -d $SURVEILR_HOME && rm temp.zip
elif [ "$PLATFORM" = "linux" ]; then
	curl -sL $DOWNLOAD_URL | tar -xz -C $SURVEILR_HOME
else
	echo "Unsupported archive format: $BUILD"
	exit 1
fi

echo "Download and extraction complete. Binary is in $SURVEILR_HOME"
