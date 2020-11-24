#!/usr/bin/env bash

# Copyright 2020 Hewlett Packard Enterprise Development LP

PACKAGING_TOOLS_ROOT="$(dirname "${BASH_SOURCE[0]}")/.."
source "${PACKAGING_TOOLS_ROOT}/lib/common.sh"

# Set defaults
: "${RELEASE_REPOS="${RELEASE_ROOT}/repos"}"
: "${NEXUS_BLOBSTORES:="${RELEASE_REPOS}/nexus-blobstores.yaml"}"

# Nexus

function repos::nexus::blobstores::init() {
    local name="${1:-"$RELEASE_NAME"}"

    if [[ ! -f "$NEXUS_BLOBSTORES" ]]; then
        mkdir -p "$(dirname "$NEXUS_BLOBSTORES")"
        cat <<EOF > "$NEXUS_BLOBSTORES"
# Copyright 2020 Hewlett Packard Enterprise Development LP
---
name: $name
EOF
        echo >&2 "$(realpath --relative-to=. "$NEXUS_BLOBSTORES"): created default blob store: $name"
    fi
}

function repos::nexus::blobstores::get() {
    [[ -f "$NEXUS_BLOBSTORES" ]] || repos::nexus::blobstores::init

    local name="$(yq r "$NEXUS_BLOBSTORES" "name")"

    if [[ -z "$name" ]]; then
        echo >&2 "error: missing blob store name: $(realpath --relative-to=. "$NEXUS_BLOBSTORES")"
        return 1
    else
        echo "$name"
        return 0
    fi
}

function repos::nexus::repository::init() {
    local format="$1"
    local name="$2"
    local blobstore="$3"
    shift 3

    local configfile="${RELEASE_REPOS}/${name}/nexus-repo.yaml"

    mkdir -p "$(dirname "$configfile")"

    cat <<EOF > "$configfile"
# Copyright 2020 Hewlett Packard Enterprise Development LP
---
name: ${name}
format: ${format}
storage:
  blobStoreName: ${blobstore}
EOF

    # add URL, if specified
    if [[ $# -gt 0 ]]; then
        cat <<EOF >> "$configfile"
proxy:
  remoteUrl: ${1}
EOF
    fi

    echo >&2 "$(realpath --relative-to=. "$configfile"): created default repository: ${name}"
}

function repos::nexus::init() {
    local format="$1"
    local name="$2"
    shift 2

    repodir="${RELEASE_REPOS}/${name}"
    if [[ -d "$repodir" ]]; then
        echo >&2 "error: directory exists: $repodir"
        exit 1
    fi

    # Create Nexus repository configuration
    : "${BLOBSTORE:="$(repos::nexus::blobstores::get)"}"
    repos::nexus::repository::init "$format" "$name" "$BLOBSTORE" "$@"
}

# Indexes

function repos::index::template::helm() {
    cat <<EOF
${1}:
  charts: []
EOF
}

function repos::index::template::rpm() {
    cat <<EOF
${1}:
  sync: true
  dir: contents
EOF
}

function repos::index::template::skopeo() {
    cat <<EOF
${1}:
  tls-verify: true
  images: []
EOF
}

function repos::index::init() {
    local template="$1"
    local name="$2"
    shift 2

    local indexfile="${RELEASE_REPOS}/${name}/index.yaml"

    if [[ -f "$indexfile" ]]; then
        echo >&2 "error: file exists: ${indexfile}"
        return 1
    fi

    mkdir -p "$(dirname "$indexfile")"

    while [[ $# -gt 0 ]]; do
        local url="$1"
        shift

        "$template" "$url" >>"$indexfile"
    done

    echo >&2 "$(realpath --relative-to=. "$indexfile"): created default container image manifest: ${url}"
}

function repos::index::init::helm() {
    repos::index::init repos::index::template::helm "$@"
}

function repos::index::init::rpm() {
    repos::index::init repos::index::template::rpm "$@"
}

function repos::index::init::skopeo() {
    repos::index::init repos::index::template::skopeo "$@"
}

# Initialization

function repos::init::docker() {
    repos::nexus::init docker "$@"
    repos::index::init::skopeo "$@"
}

function repos::init::helm() {
    repos::nexus::init helm "$@"
    repos::index::init::helm "$@"
}

function repos::init::rpm() {
    repos::nexus::init raw "$@"
    repos::index::init::rpm "$@"
}
