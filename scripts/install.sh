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

# 6. Homebrew 自動更新（毎朝7:00、Cask含む、sudo対応）
# 前提: Brewfile で pinentry-mac がインストール済み
AUTOUPDATE_PLIST="$HOME/Library/LaunchAgents/com.github.domt4.homebrew-autoupdate.plist"
echo "==> Setting up brew autoupdate..."
if brew autoupdate status 2>&1 | grep -q "is installed and running"; then
  echo "   [skip] autoupdate already running"
else
  if command -v pinentry-mac &>/dev/null; then
    brew autoupdate start --upgrade --cleanup --sudo
    echo "   [ok] autoupdate with sudo (Cask対応)"
  else
    echo "   [!] pinentry-mac が未インストール。brew install pinentry-mac を実行してください"
    brew autoupdate start --upgrade --cleanup
    echo "   [ok] autoupdate without sudo (formulaのみ確実)"
  fi
  # StartInterval(間隔) → StartCalendarInterval(毎朝7:00) に変更
  if [ -f "${AUTOUPDATE_PLIST}" ]; then
    launchctl unload "${AUTOUPDATE_PLIST}" 2>/dev/null || true
    plutil -replace StartInterval -remove "${AUTOUPDATE_PLIST}" 2>/dev/null || true
    plutil -insert StartCalendarInterval -xml \
      '<dict><key>Hour</key><integer>7</integer><key>Minute</key><integer>0</integer></dict>' \
      "${AUTOUPDATE_PLIST}" 2>/dev/null || true
    launchctl load "${AUTOUPDATE_PLIST}"
    echo "   [ok] schedule: 毎朝 7:00"
  fi
fi

echo "==> Setup complete!"
