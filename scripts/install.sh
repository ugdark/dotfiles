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

# 2. Oh My Zsh インストール
# 公式インストーラは .zshrc を上書きするため、git cloneで直接配置する
# .zshrc は stow で管理しているので、OMZ側に触らせない
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing Oh My Zsh..."
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
else
  echo "==> Oh My Zsh already installed."
fi

# 3. 必要なディレクトリ作成
echo "==> Creating required directories..."
mkdir -p "$HOME/.vimbackup"

# 4. stow でシンボリックリンク作成
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

# 5. macOS システム設定
bash "${DOTFILES_DIR}/scripts/macos.sh"

# 6. Homebrew 自動更新
echo "==> Setting up brew autoupdate..."
brew autoupdate start --upgrade --cleanup

echo "==> Setup complete!"
