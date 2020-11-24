#!/usr/bin/env bash

# Copyright 2020 Hewlett Packard Enterprise Development LP

# Common utilities, variables and checks for all scripts
set -o errexit
set -o nounset
set -o pipefail

unset CDPATH

RELEASE_ROOT="$(git rev-parse --show-toplevel)"

## Fix up RELEASE_ROOT so it's a clean path
#command -v realpath >/dev/null 2>&1 || { echo >&2 "command not found: realpath"; exit 1; }
#RELEASE_ROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")/../..")"

# Default package name to the name of the root directory
: "${RELEASE_NAME:="$(basename "$RELEASE_ROOT")"}"
