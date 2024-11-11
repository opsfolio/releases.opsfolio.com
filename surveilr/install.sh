#!/bin/bash

# Exit immediately if a command fails, and propagate errors in functions and subshells
set -eE

# Function to log errors
log_error() {
    echo "An error occurred. Check error.log for details." | tee -a error.log
    exit 1
}

# Trap errors and call the log_error function
trap 'log_error' ERR

# Detect the platform
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
echo "Detected platform: $PLATFORM"

# Set the BUILD based on the detected platform
case "$PLATFORM" in
    "darwin") BUILD="apple-darwin.zip" ;;
    "linux") BUILD="unknown-linux-gnu.tar.gz" ;;
    *"cygwin"*|*"mingw"*|*"msys"*) BUILD="pc-windows-gnu.zip" ;;
    *) echo "Unsupported platform" | tee -a error.log; exit 1 ;;
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
DOWNLOAD_URL=$(curl -s $API_URL | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | xargs -I {} echo "https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/{}/resource-surveillance_{}_x86_64-${BUILD}") || { echo "Failed to construct download URL" | tee -a error.log; exit 1; }
echo "Constructed download URL: $DOWNLOAD_URL"

# Notify about the start of the download and extraction process
echo "Starting download and extraction..."

# Download and extract the binary to the SURVEILR_HOME directory
if [ "$PLATFORM" = "darwin" ]; then
	curl -sL $DOWNLOAD_URL -o temp.zip && unzip -j -q temp.zip -d $SURVEILR_HOME && rm temp.zip || { echo "Failed to download or extract on Darwin" | tee -a error.log; exit 1; }
elif [[ "$PLATFORM" == *"cygwin"* || "$PLATFORM" == *"mingw"* || "$PLATFORM" == *"msys"* ]]; then
	curl -sL $DOWNLOAD_URL -o temp.zip && unzip -j -q temp.zip -d $SURVEILR_HOME && rm temp.zip || { echo "Failed to download or extract on Windows" | tee -a error.log; exit 1; }
elif [ "$PLATFORM" = "linux" ]; then
	curl -sL $DOWNLOAD_URL | tar -xz -C $SURVEILR_HOME || { echo "Failed to download or extract on Linux" | tee -a error.log; exit 1; }
else
	echo "Unsupported archive format: $BUILD" | tee -a error.log
	exit 1
fi

echo "Download and extraction complete. Binary is in $SURVEILR_HOME"
