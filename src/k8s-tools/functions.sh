#!/usr/bin/env bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || return 0

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
INSTALL_PATH="${INSTALL_PATH:-${HOME}/.local/bin}"

echo_stderr() {
  echo "${*}" >&2
}

is_cmd_available() {
  if ! command -v "${1}" &> /dev/null; then
    return 1
  fi
}

# making no assumptions
prereqs() {
  local required=(
    "curl"
    "jq"
    "tar"
    "install"
    "grep"
  )

  missing=()

  for cmd in "${required[@]}"; do
    if ! is_cmd_available "${cmd}"; then
      missing+=("${cmd}")
    fi
  done

  if [[ "${#missing[@]}" -gt 0 ]]; then
      echo_stderr "error: the following required commands are missing; you must check how to install them:"
      for missing_cmd in "${missing[@]}"; do
          echo_stderr "  - ${missing_cmd}"
      done
      return 1
  fi
}

gh_tarball_url() {
  local repo="${1}"
  curl --fail --silent --location "https://api.github.com/repos/${repo}/releases/latest" | jq -r .tarball_url
}

gh_version() {
  local tarball_url="${1}"
  grep -o '[^/v]*$' <<< "${tarball_url}"
}

gh_download_url() {
  local repo="${1}"
  local version="${2}"
  local file_name="${3}"
  local download_url="https://github.com/${repo}/releases/download/${version}/${file_name}"
  echo "${download_url}"
}

extract_tar() {
  local tar_file_path="${1}"
  local target_dir="${2}"
  tar \
    --extract \
    --gzip \
    --file "${tar_file_path}" \
    --directory "${target_dir}"
}

prepare_install() {
  local install_path="${INSTALL_PATH:-/usr/local/bin}"
  mkdir -p "${install_path}"
}

download() {
  local download_url="${1}"
  local file_path="${2}"
  curl \
    --fail \
    --silent \
    --location \
    --output "${file_path}" \
    "${download_url}"
}

cleanup() {
  local target_dir="${1:-}"
  if [ -n "${target_dir}" ]; then
    rm -rf "${target_dir}"
  fi
}

install_kind() {
  local bin_name="kind"
  if ! is_cmd_available "${bin_name}"; then
    local repo tarball_url version file_pattern download_url tmp_dir

    repo="kubernetes-sigs/kind"
    tarball_url=$(gh_tarball_url "${repo}")
    version=$(gh_version "${tarball_url}")
    file_pattern="kind-${OS}-${ARCH}"
    download_url=$(gh_download_url "${repo}" "v${version}" "${file_pattern}")
    tmp_dir=$(mktemp -d)

    trap 'cleanup ${tmp_dir}' RETURN

    download "${download_url}" "${tmp_dir}/${bin_name}" && \
    install "${tmp_dir}/${bin_name}" "${INSTALL_PATH}" && \
    echo_stderr "installed ${bin_name} version ${version}"
  fi
}

install_kubectl() {
  local bin_name="kubectl"
  if ! is_cmd_available "${bin_name}"; then
    local version download_url tmp_dir

    version=$(curl --fail --silent --location https://dl.k8s.io/release/stable.txt)
    download_url="https://dl.k8s.io/release/${version}/bin/${OS}/${ARCH}/kubectl"
    tmp_dir=$(mktemp -d)

    trap 'cleanup ${tmp_dir}' RETURN

    download "${download_url}" "${tmp_dir}/${bin_name}" && \

    if [ -f "${tmp_dir}/${bin_name}" ]; then
      install "${tmp_dir}/${bin_name}" "${INSTALL_PATH}" && \
      echo_stderr "installed ${bin_name} version ${version}"
    else
      echo_stderr "error: ${bin_name} not installed"
      exit 1
    fi
  fi
}

install_helm() {
  local bin_name="helm"
  if ! is_cmd_available "${bin_name}"; then
    local repo tarball_url version file_pattern download_url tmp_dir

    repo="helm/helm"
    tarball_url=$(gh_tarball_url "${repo}")
    version=$(gh_version "${tarball_url}")
    file_pattern="${bin_name}-v${version}-${OS}-${ARCH}.tar.gz"
    download_url="https://get.helm.sh/${file_pattern}"
    tmp_dir=$(mktemp -d)

    trap 'cleanup ${tmp_dir}' RETURN

    download "${download_url}" "${tmp_dir}/${file_pattern}" && \
    extract_tar "${tmp_dir}/${file_pattern}" "${tmp_dir}" && \
    if [ -f "${tmp_dir}/${OS}-${ARCH}/${bin_name}" ]; then
      install "${tmp_dir}/${OS}-${ARCH}/${bin_name}" "${INSTALL_PATH}" && \
      echo_stderr "installed ${bin_name} version ${version}"
    else
      echo_stderr "error: ${bin_name} not installed"
      exit 1
    fi
  fi
}

install_kustomize() {
  local bin_name="kustomize"
  if ! is_cmd_available "${bin_name}"; then
    local repo tarball_url version file_pattern download_url tmp_dir

    repo="kubernetes-sigs/kustomize"
    tarball_url=$(gh_tarball_url "${repo}")
    version=$(gh_version "${tarball_url}")
    file_pattern="${bin_name}_v${version}_${OS}_${ARCH}.tar.gz"
    download_url="https://github.com/${repo}/releases/download/${bin_name}/v${version}/${file_pattern}"
    tmp_dir=$(mktemp -d)

    trap 'cleanup ${tmp_dir}' RETURN

    download "${download_url}" "${tmp_dir}/${file_pattern}"
    extract_tar "${tmp_dir}/${file_pattern}" "${tmp_dir}"
    if [ -f  "${tmp_dir}/${bin_name}" ]; then
      install "${tmp_dir}/${bin_name}" "${INSTALL_PATH}"
      echo_stderr "installed ${bin_name} version ${version}"
    else
      echo_stderr "error: ${bin_name} not installed"
      exit 1
    fi
  fi

}

install_skaffold() {
  local bin_name="skaffold"
  if ! is_cmd_available "${bin_name}"; then
    local repo tarball_url version file_pattern download_url tmp_dir

    repo="GoogleContainerTools/skaffold"
    tarball_url=$(gh_tarball_url "${repo}")
    version=$(gh_version "${tarball_url}")
    file_pattern="${bin_name}-${OS}-${ARCH}"
    download_url=$(gh_download_url "${repo}" "v${version}" "${file_pattern}")
    tmp_dir=$(mktemp -d)

    trap 'cleanup ${tmp_dir}' RETURN

    download "${download_url}" "${tmp_dir}/${file_pattern}"
    if [ -f "${tmp_dir}/${file_pattern}" ]; then
      install "${tmp_dir}/${file_pattern}" "${INSTALL_PATH}/${bin_name}"
      echo_stderr "installed ${bin_name} version ${version}"
    else
      echo_stderr "error: ${bin_name} not installed"
      exit 1
    fi
  fi

}

install_k9s() {
  local bin_name="k9s"
  if ! is_cmd_available "${bin_name}"; then
    local repo tarball_url version file_pattern download_url tmp_dir

    repo="derailed/k9s"
    tarball_url=$(gh_tarball_url "${repo}")
    version=$(gh_version "${tarball_url}")
    file_pattern="k9s_Linux_${ARCH}.tar.gz"
    download_url=$(gh_download_url "${repo}" "v${version}" "${file_pattern}")
    tmp_dir=$(mktemp -d)

    trap 'cleanup ${tmp_dir}' RETURN

    download "${download_url}" "${tmp_dir}/${file_pattern}"
    extract_tar "${tmp_dir}/${file_pattern}" "${tmp_dir}"
    if [ -f "${tmp_dir}/${bin_name}" ]; then
      install "${tmp_dir}/${bin_name}" "${INSTALL_PATH}"
      echo_stderr "installed ${bin_name} version ${version}"
    else
      echo_stderr "error: ${bin_name} not installed"
      exit 1
    fi
  fi

}
