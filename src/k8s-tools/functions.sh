#!/usr/bin/env bash

TARGETARCH="${TARGETARCH:-arm64}"
TARGETOS="${TARGETARCH:-linux}"
INSTALL_PATH="${INSTALL_PATH:-${HOME}/.local/bin}"

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
  check_cmd jq
  check_cmd tar
  check_cmd install
  check_cmd grep
}

gh_tarball_url() {
  local REPO="${1}"
  curl --silent "https://api.github.com/repos/${REPO}/releases/latest" | jq -r .tarball_url
}

gh_version() {
  local tarball_url="${1}"
  grep -o '[^/v]*$' <<< "${tarball_url}"
}

gh_download_url() {
  local REPO="${1}"
  local VERSION="${2}"
  local FILE_NAME="${3}"
  local download_url="https://github.com/${REPO}/releases/download/${VERSION}/${FILE_NAME}"
  echo "${download_url}"
}

extract_tar() {
  local TAR_FILE="${1}"
  local TARGET_DIR="${2}"
  tar -xzf "${TAR_FILE}" --directory "${TARGET_DIR}"
}

prepare_install() {
  local INSTALL_PATH="${INSTALL_PATH:-${HOME}/.local/bin}"
  mkdir -p "${INSTALL_PATH}"
}

download() {
  local DOWNLOAD_URL="${1}"
  local FILE_PATH="${2}"
  curl \
    --silent
    --location \
    --output "${FILE_PATH}" \
    "${DOWNLOAD_URL}"
}

cleanup() {
  local TARGET_DIR="${1}"
  rm -rf "${TARGET_DIR}"
}

install_kind() {
  local REPO="kubernetes-sigs/kind"
  local BIN_NAME="kind"
  local FILE_PATTERN="kind-${TARGETOS}-${TARGETARCH}"
  local TARBALL_URL=$(gh_tarball_url "${REPO}")
  local VERSION=$(gh_version "${TARBALL_URL}")
  local DOWNLOAD_URL=$(gh_download_url "${REPO}" "${VERSION}" "${FILE_PATTERN}")
  local TMP_DIR=$(mktemp -d -t "${BIN_NAME}")
  trap "cleanup ${TMP_DIR}" RETURN
  download "${DOWNLOAD_URL}" "${TMP_DIR}/${BIN_NAME}"
  install "${TMP_DIR}/${BIN_NAME}" "${INSTALL_PATH}"
  echo "installed ${BIN_NAME} version ${VERSION}"
}

install_helm() {

}

install_kubectl() {

}

install_skaffold() {

}

install_k9s() {
  local REPO="derailed/k9s"
  local BIN_NAME="k9s"
  local FILE_PATTERN="k9s_Linux_${TARGETARCH}.tar.gz"
  local TARBALL_URL=$(gh_tarball_url "${REPO}")
  local VERSION=$(gh_version "${TARBALL_URL}")
  local DOWNLOAD_URL=$(gh_download_url "${REPO}" "${VERSION}" "${FILE_PATTERN}")

  echo "INSPECT:"
  echo "Install: ${BIN_NAME} version ${VERSION}"
  echo "Download URL: ${DOWNLOAD_URL}"

}


export -f err_log
export -f check_cmd
export -f prereqs
export -f gh_tarball_url
export -f gh_version
export -f gh_download_url
export -f extract_tar
export -f prepare_install
export -f download
export -f cleanup
export -f install_kind