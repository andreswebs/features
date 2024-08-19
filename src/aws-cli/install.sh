#!/usr/bin/env bash
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html

set -o errexit
set -o pipefail
set -o nounset

export TARGETOS="${TARGETOS:-linux}"
export TARGETARCH="${TARGETARCH:-amd64}"

err_log() {
  >&2 echo "${1}"
}

check_cmd() {
  if ! command -v "${1}" &> /dev/null; then
    err_log "error: ${1} command is missing; you must check how to install it"
    exit 1
  fi
}

# making no assumptions
prereqs() {
  check_cmd curl
  check_cmd unzip
}

cleanup() {
  local TARGET_DIR="${1}"
  rm -rf "${TARGET_DIR}"
}

main() {
  architecture=$(dpkg --print-architecture)
  case "${architecture}" in
    amd64) export TARGETARCH="amd64" ;;
    arm64) export TARGETARCH="arm64" ;;
    *)
      echo "Machine architecture '${architecture}' is not supported. Please use an x86-64 or ARM64 machine."
      exit 1
  esac

  if ! command -v aws &> /dev/null; then
    if [ "${TARGETARCH}" = "amd64" ]; then export AWS_ARCH="x86_64" ; fi
    if [ "${TARGETARCH}" = "arm64" ]; then export AWS_ARCH="aarch64" ; fi
    local TMP_DIR="$(mktemp -d -t awscliv2.XXXXXXX)"
    local FILE_PATTERN="awscli-exe-${TARGETOS}-${AWS_ARCH}.zip"
    trap "cleanup ${TMP_DIR}" RETURN

    curl \
        --fail \
        --silent \
        --location \
        --output "${TMP_DIR}/${FILE_PATTERN}" \
        "https://awscli.amazonaws.com/${FILE_PATTERN}" && \
    unzip -qq "${TMP_DIR}/${FILE_PATTERN}" -d "${TMP_DIR}"

    cd "${X_WORKDIR}" || exit 1
    aws/install
  fi

}

main
