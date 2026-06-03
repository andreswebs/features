#!/usr/bin/env bash

# shellcheck disable=SC2016

set -o errexit -o nounset -o pipefail

_REMOTE_USER="${_REMOTE_USER:-}"
_REMOTE_USER_HOME="${_REMOTE_USER_HOME:-}"
TARGET_HOME="${HOME}"
DIRENV_BIN_DIR="${DIRENV_BIN_DIR:-}"

if [ -n "${_REMOTE_USER_HOME:-}" ]; then
    TARGET_HOME="${_REMOTE_USER_HOME}"
fi

echo_stderr() {
    echo "${*}" >&2
}

is_cmd_available() {
    if ! command -v "${1}" &>/dev/null; then
        return 1
    fi
}

# making no assumptions
prereqs() {
    local required=(
        "curl"
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

touch "${TARGET_HOME}/.zshrc"
touch "${TARGET_HOME}/.bashrc"

if ! is_cmd_available "direnv"; then
    if [ -n "${DIRENV_BIN_DIR:-}" ]; then
        export bin_path="${DIRENV_BIN_DIR}"
    fi
    curl -fsSL https://direnv.net/install.sh | bash
    unset bin_path
fi

if ! grep -q 'eval "$(direnv hook bash)"' "${TARGET_HOME}/.bashrc"; then
    echo >>"${TARGET_HOME}/.bashrc"
    cat <<'EOT' >>"${TARGET_HOME}/.bashrc"
if command -v direnv > /dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi
EOT
fi

if ! grep -q 'eval "$(direnv hook zsh)"' "${TARGET_HOME}/.zshrc"; then
    echo >>"${TARGET_HOME}/.zshrc"
    cat <<'EOT' >>"${TARGET_HOME}/.zshrc"
if command -v direnv > /dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi
EOT
fi

if [ -n "${_REMOTE_USER:-}" ]; then
    chown "${_REMOTE_USER}:${_REMOTE_USER}" "${TARGET_HOME}/.bashrc"
    chown "${_REMOTE_USER}:${_REMOTE_USER}" "${TARGET_HOME}/.zshrc"
fi
