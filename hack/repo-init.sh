#!/usr/bin/env bash

# Copyright 2020 Hewlett Packard Enterprise Development LP

PACKAGING_TOOLS_ROOT="$(dirname "${BASH_SOURCE[0]}")/.."
source "${PACKAGING_TOOLS_ROOT}/hack/lib/repos.sh"

usage() {
    echo >&2 "usage: ${0##*/} {docker,helm,rpm} NAME [URL ...]"
    exit 1
}

[[ $# -gt 1 ]] || usage

repotype="$1"
shift

case "$repotype" in
docker|helm|rpm)
    repos::init::$repotype "$@"
    ;;
*)
    echo >&2 "error: unsupported repository type: ${repotype}"
    usage
    ;;
esac
