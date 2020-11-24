#!/usr/bin/env bash

# Copyright 2020 Hewlett Packard Enterprise Development LP

# Initialize Nexus blob stores

PACKAGING_TOOLS_ROOT="$(dirname "${BASH_SOURCE[0]}")/.."
source "$PACKAGING_TOOLS_ROOT/hack/lib/repos.sh"

if [[ $# -lt 1 ]]; then
    echo >&2 "usage: ${0##*/} NAME ..."
    exit 1
fi

while [[ $# -gt 0 ]]; do
    repos::nexus::blobstores::init "$1"
    shift
done
