#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source "${SCRIPT_DIR}/functions.sh"

main() {

  architecture=$(dpkg --print-architecture)
  case "${architecture}" in
    amd64) TARGETARCH="amd64" ;;
    arm64) TARGETARCH="arm64" ;;
    *)
      echo "Machine architecture '${architecture}' is not supported. Please use an x86-64 or ARM64 machine."
      exit 1
  esac

  prereqs
  install_kind
  install_k9s

}

# helm

# kubectl

# skaffold

# k9s

