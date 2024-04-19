#!/bin/sh

# Strict error handling.
set -euo pipefail

# Ensure sudo is available.
sudo -v

echo "Let's install Go! 🚀"

# Get latest Go version.
version=$(curl -s "https://go.dev/dl/?mode=json" | jq -r '.[0].version')
source_url="https://go.dev/dl/$version.darwin-arm64.tar.gz"
# Trim the 'go' prefix and make it pretty.
version_pretty="Go @ v${version:2}"

# Temporary directory to download the archive.
tmpdir=$(mktemp -d) && trap "rm -rf $tmpdir" EXIT

# Download the archive.
echo "Downloading $version_pretty..."
if ! curl -sSL "$source_url" | tar -C "$tmpdir" -xz; then
	echo "Failed to download Go @ v$version_pretty"
  exit 1
fi

# Move the new version to /usr/local.
sudo mv "$tmpdir/go" /usr/local

# Confirm the new version.
if [ $? -eq 0 ]; then
	echo "Successfully installed $version_pretty"
else
	echo "Failed to install $version_pretty"
fi
