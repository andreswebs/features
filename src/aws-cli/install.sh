#!/usr/bin/env bash
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html

set -o errexit -o nounset -o pipefail

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

echo_stderr() {
  echo "${*}" >&2
}

is_cmd_available() {
  if ! command -v "${1}" &> /dev/null; then
    return 1
  fi
}

check_cmd() {
  local cmd="${1}"
  if ! is_cmd_available "${cmd}"; then
    echo_stderr "error: ${cmd} command is missing; you must check how to install it"
    exit 1
  fi
}

# making no assumptions
prereqs() {
  local required=(
    "curl"
    "unzip"
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

download() {
  local download_url="${1}"
  local file_path="${2}"
  curl \
    --silent \
    --fail \
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

main() {
  local aws_arch="${ARCH}"

  if ! is_cmd_available "aws"; then
    prereqs

    if [ "${ARCH}" = "amd64" ]; then aws_arch="x86_64" ; fi
    if [ "${ARCH}" = "arm64" ]; then aws_arch="aarch64" ; fi

    case "${ARCH}" in
      x86_64) ;;
      aarch64) ;;
      *)
        echo_stderr "error: machine architecture '${aws_arch}' is not supported. Please use an x86-64 or ARM64 machine."
        exit 1
    esac

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    trap 'cleanup ${tmp_dir}' RETURN

    local file_pattern="awscli-exe-${OS}-${aws_arch}.zip"

    download "https://awscli.amazonaws.com/${file_pattern}" "${tmp_dir}/${file_pattern}" && \
    unzip -qq "${tmp_dir}/${file_pattern}" -d "${tmp_dir}"

    cd "${tmp_dir}" || exit 1
    aws/install
  fi

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
