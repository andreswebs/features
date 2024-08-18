#!/usr/bin/env bash

export TARGETARCH="${TARGETARCH:-amd64}"
export TARGETOS="${TARGETOS:-linux}"
export INSTALL_PATH="${INSTALL_PATH:-/usr/local/bin}"

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
  local TAR_FILE_PATH="${1}"
  local TARGET_DIR="${2}"
  tar -xzf "${TAR_FILE_PATH}" --directory "${TARGET_DIR}"
}

prepare_install() {
  local INSTALL_PATH="${INSTALL_PATH:-/usr/local/bin}"
  mkdir -p "${INSTALL_PATH}"
}

download() {
  local DOWNLOAD_URL="${1}"
  local FILE_PATH="${2}"
  curl \
    --silent \
    --location \
    --output "${FILE_PATH}" \
    "${DOWNLOAD_URL}"
}

cleanup() {
  local TARGET_DIR="${1}"
  rm -rf "${TARGET_DIR}"
}

install_kind() {
  local BIN_NAME="kind"
  if ! command -v "${BIN_NAME}" &> /dev/null; then
    local REPO="kubernetes-sigs/kind"
    local TARBALL_URL=$(gh_tarball_url "${REPO}")
    local VERSION=$(gh_version "${TARBALL_URL}")
    local FILE_PATTERN="kind-${TARGETOS}-${TARGETARCH}"
    local DOWNLOAD_URL=$(gh_download_url "${REPO}" "v${VERSION}" "${FILE_PATTERN}")
    local TMP_DIR=$(mktemp -d -t "${BIN_NAME}.XXXXXXX")

    trap "cleanup ${TMP_DIR}" RETURN

    download "${DOWNLOAD_URL}" "${TMP_DIR}/${BIN_NAME}" && \
    install "${TMP_DIR}/${BIN_NAME}" "${INSTALL_PATH}" && \
    echo "installed ${BIN_NAME} version ${VERSION}"
  fi

}

install_kubectl() {
  local BIN_NAME="kubectl"
  if ! command -v "${BIN_NAME}" &> /dev/null; then
    local VERSION=$(curl --location --silent https://dl.k8s.io/release/stable.txt)
    local DOWNLOAD_URL="https://dl.k8s.io/release/${VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl"
    local TMP_DIR=$(mktemp -d -t "${BIN_NAME}.XXXXXXX")

    trap "cleanup ${TMP_DIR}" RETURN

    download "${DOWNLOAD_URL}" "${TMP_DIR}/${BIN_NAME}" && \

    if [ -f "${TMP_DIR}/${BIN_NAME}" ]; then
      install "${TMP_DIR}/${BIN_NAME}" "${INSTALL_PATH}" && \
      echo "installed ${BIN_NAME} version ${VERSION}"
    else
      err_log "error: ${BIN_NAME} not installed"
      exit 1
    fi
  fi
}

install_helm() {
  local BIN_NAME="helm"
  if ! command -v "${BIN_NAME}" &> /dev/null; then
    local REPO="helm/helm"
    local TARBALL_URL=$(gh_tarball_url "${REPO}")
    local VERSION=$(gh_version "${TARBALL_URL}")
    local FILE_PATTERN="${BIN_NAME}-v${VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz"
    local DOWNLOAD_URL="https://get.helm.sh/${FILE_PATTERN}"
    local TMP_DIR=$(mktemp -d -t "${BIN_NAME}.XXXXXXX")

    trap "cleanup ${TMP_DIR}" RETURN

    download "${DOWNLOAD_URL}" "${TMP_DIR}/${FILE_PATTERN}" && \
    extract_tar "${TMP_DIR}/${FILE_PATTERN}" "${TMP_DIR}" && \
    if [ -f "${TMP_DIR}/${TARGETOS}-${TARGETARCH}/${BIN_NAME}" ]; then
      install "${TMP_DIR}/${TARGETOS}-${TARGETARCH}/${BIN_NAME}" "${INSTALL_PATH}" && \
      echo "installed ${BIN_NAME} version ${VERSION}"
    else
      err_log "error: ${BIN_NAME} not installed"
      exit 1
    fi
  fi
}

install_kustomize() {
  local BIN_NAME="kustomize"
  if ! command -v "${BIN_NAME}" &> /dev/null; then
    local REPO="kubernetes-sigs/kustomize"
    local TARBALL_URL=$(gh_tarball_url "${REPO}")
    local VERSION=$(gh_version "${TARBALL_URL}")
    local FILE_PATTERN="${BIN_NAME}_v${VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz"
    local DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${BIN_NAME}/v${VERSION}/${FILE_PATTERN}"
    local TMP_DIR=$(mktemp -d -t "${BIN_NAME}.XXXXXXX")

  # https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.4.3/kustomize_v5.4.3_linux_amd64.tar.gz

    trap "cleanup ${TMP_DIR}" RETURN

    download "${DOWNLOAD_URL}" "${TMP_DIR}/${FILE_PATTERN}" && \
    extract_tar "${TMP_DIR}/${FILE_PATTERN}" "${TMP_DIR}" && \
    if [ -f  "${TMP_DIR}/${BIN_NAME}" ]; then
      install "${TMP_DIR}/${BIN_NAME}" "${INSTALL_PATH}" && \
      echo "installed ${BIN_NAME} version ${VERSION}"
    else
      err_log "error: ${BIN_NAME} not installed"
      exit 1
    fi
  fi

}

install_skaffold() {
  local BIN_NAME="skaffold"
  if ! command -v "${BIN_NAME}" &> /dev/null; then
    local REPO="GoogleContainerTools/skaffold"
    local TARBALL_URL=$(gh_tarball_url "${REPO}")
    local VERSION=$(gh_version "${TARBALL_URL}")
    local FILE_PATTERN="${BIN_NAME}-${TARGETOS}-${TARGETARCH}"
    local DOWNLOAD_URL=$(gh_download_url "${REPO}" "v${VERSION}" "${FILE_PATTERN}")
    local TMP_DIR=$(mktemp -d -t "${BIN_NAME}.XXXXXXX")

    trap "cleanup ${TMP_DIR}" RETURN

    download "${DOWNLOAD_URL}" "${TMP_DIR}/${FILE_PATTERN}" && \
    if [ -f "${TMP_DIR}/${FILE_PATTERN}" ]; then
      install "${TMP_DIR}/${FILE_PATTERN}" "${INSTALL_PATH}/${BIN_NAME}" && \
      echo "installed ${BIN_NAME} version ${VERSION}"
    else
      err_log "error: ${BIN_NAME} not installed"
      exit 1
    fi
  fi

}

install_k9s() {
  local BIN_NAME="k9s"
  if ! command -v "${BIN_NAME}" &> /dev/null; then
    local REPO="derailed/k9s"
    local FILE_PATTERN="k9s_Linux_${TARGETARCH}.tar.gz"
    local TARBALL_URL=$(gh_tarball_url "${REPO}")
    local VERSION=$(gh_version "${TARBALL_URL}")
    local DOWNLOAD_URL=$(gh_download_url "${REPO}" "v${VERSION}" "${FILE_PATTERN}")
    local TMP_DIR=$(mktemp -d -t "${BIN_NAME}.XXXXXXX")

    trap "cleanup ${TMP_DIR}" RETURN

    download "${DOWNLOAD_URL}" "${TMP_DIR}/${FILE_PATTERN}" && \
    extract_tar "${TMP_DIR}/${FILE_PATTERN}" "${TMP_DIR}" && \
    if [ -f "${TMP_DIR}/${BIN_NAME}" ]; then
      install "${TMP_DIR}/${BIN_NAME}" "${INSTALL_PATH}" && \
      echo "installed ${BIN_NAME} version ${VERSION}"
    else
      err_log "error: ${BIN_NAME} not installed"
      exit 1
    fi
  fi

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
export -f install_kubectl
export -f install_helm
export -f install_k9s
export -f install_kustomize
export -f install_skaffold
