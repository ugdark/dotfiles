#!/bin/bash
#
# dotfiles セットアップスクリプト
# Usage: git clone https://github.com/ugdark/dotfiles.git ~/.dotfiles && bash ~/.dotfiles/scripts/install.sh
#
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> dotfiles setup: ${DOTFILES_DIR}"

# 1. Homebrew + パッケージインストール
bash "${DOTFILES_DIR}/scripts/brew.sh"

# 2. stow でシンボリックリンク作成
echo "==> Creating symlinks with stow..."
STOW_PACKAGES=(zsh vim git editorconfig claude)

for pkg in "${STOW_PACKAGES[@]}"; do
  if [ -d "${DOTFILES_DIR}/settings/${pkg}" ]; then
    stow -d "${DOTFILES_DIR}/settings" -t "$HOME" --adopt "${pkg}"
    echo "   [ok] ${pkg}"
  else
    echo "   [skip] ${pkg} (not found)"
  fi
done

# 3. macOS システム設定
bash "${DOTFILES_DIR}/scripts/macos.sh"

# 4. Homebrew 自動更新
echo "==> Setting up brew autoupdate..."
brew autoupdate start --upgrade --cleanup

echo "==> Setup complete!"
