#!/bin/sh

curl -sS https://starship.rs/install.sh | sh
echo "eval \"\$(starship init zsh)\"" >> "${HOME}/.zshrc"

git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.zsh/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.zsh/zsh-syntax-highlighting"

echo "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "${HOME}/.zshrc"
echo "source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "${HOME}/.zshrc"

# mkdir -p ~/.config && printf "[container]\ndisabled = true" >> ~/.config/starship.toml
