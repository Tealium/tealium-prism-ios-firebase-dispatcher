#!/usr/bin/env bash

set -euo pipefail

# Directory of this script (…/scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Repo root assumed to be one level up
REPO_ROOT="${SCRIPT_DIR}/.."

get_version() {
  local constants='' regex=''

  constants=$(<"${REPO_ROOT}/Sources/TealiumPrismFirebase/Internal/FirebaseConstants.swift")
  regex='^.*static let version = "([0-9\.]*)"'

  if [[ $constants =~ $regex ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    echo "Couldn't match the library version, exiting" >&2
    return 1
  fi
}

# If executed directly: just validate & print
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  version="$(get_version)"
  echo "Success: found library version: $version"
fi
