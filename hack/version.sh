#!/usr/bin/env bash

# This script computes version information for the Migration Planner UI.
# It can be sourced to set environment variables or executed to print them.
#
# Usage:
#   ./hack/version.sh                      # Print version variables
#   ./hack/version.sh --update-package-json # Update package.json with version info
#   source ./hack/version.sh               # Set environment variables

set -o errexit
set -o nounset
set -o pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGE_JSON="${REPO_ROOT}/package.json"

# Get git information
GIT_COMMIT="${SOURCE_GIT_COMMIT:-$(git rev-parse HEAD 2>/dev/null || echo 'unknown')}"
GIT_TAG="${SOURCE_GIT_TAG:-$(git describe --tags --always --abbrev=7 --match '[0-9]*\.[0-9]*\.[0-9]*' --match 'v[0-9]*\.[0-9]*\.[0-9]*' 2>/dev/null || echo 'v0.0.0-unknown')}"

# Export version variables
export MIGRATION_PLANNER_UI_GIT_COMMIT="${GIT_COMMIT}"
export MIGRATION_PLANNER_UI_VERSION="${GIT_TAG}"

# Function to update package.json
update_package_json() {
  echo "Updating ${PACKAGE_JSON} with version information..."

  # Check if jq is installed
  if ! command -v jq &> /dev/null; then
    echo "Error: jq is required to update package.json. Please install jq."
    exit 1
  fi

  # Update package.json using jq
  jq --arg version "${MIGRATION_PLANNER_UI_VERSION}" \
     --arg commit "${MIGRATION_PLANNER_UI_GIT_COMMIT}" \
     '.uiVersionName = $version | .uiGitCommit = $commit' \
     "${PACKAGE_JSON}" > "${PACKAGE_JSON}.tmp"

  mv "${PACKAGE_JSON}.tmp" "${PACKAGE_JSON}"

  echo "✅ Updated package.json:"
  echo "   uiVersionName: ${MIGRATION_PLANNER_UI_VERSION}"
  echo "   uiGitCommit: ${MIGRATION_PLANNER_UI_GIT_COMMIT}"
}

# If executed (not sourced), handle command line arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ "${1:-}" == "--update-package-json" ]]; then
    update_package_json
  else
    echo "MIGRATION_PLANNER_UI_GIT_COMMIT=${MIGRATION_PLANNER_UI_GIT_COMMIT}"
    echo "MIGRATION_PLANNER_UI_VERSION=${MIGRATION_PLANNER_UI_VERSION}"
  fi
fi
