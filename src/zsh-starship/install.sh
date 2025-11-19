#!/usr/bin/env bash

# shellcheck disable=SC2016

set -o errexit -o nounset -o pipefail

_REMOTE_USER="${_REMOTE_USER:-}"
_REMOTE_USER_HOME="${_REMOTE_USER_HOME:-}"
TARGET_HOME="${HOME}"
STARSHIP_BIN_DIR="${STARSHIP_BIN_DIR:-}"

if [ -n "${_REMOTE_USER_HOME}" ]; then
  TARGET_HOME="${_REMOTE_USER_HOME}"
fi

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
    "git"
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

mkdir -p "${TARGET_HOME}/.zsh"
touch "${TARGET_HOME}/.zshrc"

if ! is_cmd_available "starship"; then
  if [ -n "${STARSHIP_BIN_DIR}" ]; then
    export BIN_DIR="${STARSHIP_BIN_DIR}"
  fi
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
  unset BIN_DIR
fi

if ! grep -q 'eval "$(starship init zsh)"' "${TARGET_HOME}/.zshrc"; then
  echo >> "${TARGET_HOME}/.zshrc"
  cat <<'EOT' >> "${TARGET_HOME}/.zshrc"
if command -v starship > /dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
EOT
fi

if [ ! -d "${TARGET_HOME}/.zsh/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "${TARGET_HOME}/.zsh/zsh-autosuggestions"
fi

if ! grep -q 'source "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"' "${TARGET_HOME}/.zshrc"; then
  echo >> "${TARGET_HOME}/.zshrc"
  cat <<'EOT' >> "${TARGET_HOME}/.zshrc"
if [ -d "${HOME}/.zsh/zsh-autosuggestions" ]; then
  source "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
EOT
fi

if [ ! -d "${TARGET_HOME}/.zsh/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${TARGET_HOME}/.zsh/zsh-syntax-highlighting"
fi

if ! grep -q 'source "${HOME}/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"' "${TARGET_HOME}/.zshrc"; then
  echo >> "${TARGET_HOME}/.zshrc"
  cat <<'EOT' >> "${TARGET_HOME}/.zshrc"
if [ -d "${HOME}/.zsh/zsh-syntax-highlighting" ]; then
  source "${HOME}/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
EOT
fi

if [ -n "${_REMOTE_USER}" ]; then
  chown --recursive "${_REMOTE_USER}:${_REMOTE_USER}" "${TARGET_HOME}/.zsh"
  chown "${_REMOTE_USER}:${_REMOTE_USER}" "${TARGET_HOME}/.zshrc"
fi
