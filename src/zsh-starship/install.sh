#!/usr/bin/env sh

TARGET_HOME="${HOME}"

if [ -n "${_REMOTE_USER_HOME}" ]; then
  TARGET_HOME="${_REMOTE_USER_HOME}"
fi

mkdir --parents "${TARGET_HOME}/.zsh"
touch "${TARGET_HOME}/.zshrc"

STARSHIP_BIN_DIR="${STARSHIP_BIN_DIR:-'/usr/local/bin'}"

if ! command -v starship &> /dev/null; then
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "${STARSHIP_BIN_DIR}"
fi

if ! grep -q 'eval "$(starship init zsh)"' "${TARGET_HOME}/.zshrc"; then
  echo >> "${TARGET_HOME}/.zshrc"
  cat << 'EOT' >> "${TARGET_HOME}/.zshrc"
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi
EOT
fi

if [ ! -d "${TARGET_HOME}/.zsh/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "${TARGET_HOME}/.zsh/zsh-autosuggestions"
fi

if ! grep -q 'source "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"' "${TARGET_HOME}/.zshrc"; then
  echo >> "${TARGET_HOME}/.zshrc"
  cat << 'EOT' >> "${TARGET_HOME}/.zshrc"
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
  cat << 'EOT' >> "${TARGET_HOME}/.zshrc"
if [ -d "${HOME}/.zsh/zsh-syntax-highlighting" ]; then
  source "${HOME}/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
EOT
fi

if [ -n "${_REMOTE_USER}" ]; then
  chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "${TARGET_HOME}/.zsh"
  chown "${_REMOTE_USER}:${_REMOTE_USER}" "${TARGET_HOME}/.zshrc"
fi
