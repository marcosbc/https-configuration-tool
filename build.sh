#!/bin/bash

set -euo pipefail

LEGO_VERSION=2.5.0
REQUIRED_PROGRAMS=(
    # VMware InstallBuilder
    "builder"
)

# Check requirements
for program in "${REQUIRED_PROGRAMS[@]}"; do
    if ! which "$program" >/dev/null 2>&1; then
        echo "Program ${program} is not in your PATH, check that your requirements are installed"
        exit 1
    fi
done
if [[ ! -f bncert.xml ]]; then
    echo "This program must be executed from within the same directory it is located"
    exit 1
fi

# Download lego if it does not yet exist
if [[ ! -f lego ]]; then
    curl -L "https://github.com/go-acme/lego/releases/download/v${LEGO_VERSION}/lego_v${LEGO_VERSION}_linux_amd64.tar.gz" | tar xz lego
fi

INSTALLBUILDER_DIR="$(dirname "$(dirname "$(readlink "$(which "builder")")")")"

# Build the auto-updater
"${INSTALLBUILDER_DIR}/autoupdate/bin/customize."* build bncert-auto-updater.xml linux-x64
mv "${INSTALLBUILDER_DIR}/autoupdate/output/autoupdate-linux-x64.run" autoupdater

# Build the software
"${INSTALLBUILDER_DIR}/bin/builder" build bncert.xml linux-x64 --setvars bundled_lego_version="$LEGO_VERSION"
mv "${INSTALLBUILDER_DIR}/output/bncert-"*".run" .
