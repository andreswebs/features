#!/usr/bin/env sh

mkdir --parents "${HOME}/.zsh"
touch "${HOME}/.zshrc"

STARSHIP_BIN_DIR="${STARSHIP_BIN_DIR:-/usr/local/bin}"

if ! command -v starship &> /dev/null; then
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "${STARSHIP_BIN_DIR}"
fi

if ! grep -q 'eval "$(starship init zsh)"' "${HOME}/.zshrc"; then
  echo >> "${HOME}/.zshrc"
  cat << 'EOT' >> "${HOME}/.zshrc"
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi
EOT
fi

if [ ! -d "${HOME}/.zsh/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.zsh/zsh-autosuggestions"
fi

if ! grep -q 'source "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"' "${HOME}/.zshrc"; then
  echo >> "${HOME}/.zshrc"
  cat << 'EOT' >> "${HOME}/.zshrc"
if [ -d "${HOME}/.zsh/zsh-autosuggestions" ]; then
  source "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
EOT
fi

if [ ! -d "${HOME}/.zsh/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.zsh/zsh-syntax-highlighting"
fi

if ! grep -q 'source "${HOME}/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"' "${HOME}/.zshrc"; then
  echo >> "${HOME}/.zshrc"
  cat << 'EOT' >> "${HOME}/.zshrc"
if [ -d "${HOME}/.zsh/zsh-syntax-highlighting" ]; then
  source "${HOME}/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
EOT
fi
