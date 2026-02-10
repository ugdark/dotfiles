#!/bin/bash
#
# Homebrew インストール + パッケージセットアップ
#
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Xcode Command Line Tools がなければインストール
if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "   インストール完了後、再度このスクリプトを実行してください"
  exit 0
fi

# Homebrew がなければインストール
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "==> Homebrew already installed"
fi

# brew update
echo "==> Updating Homebrew..."
brew update

# Brewfile からパッケージインストール
BREWFILE="${DOTFILES_DIR}/Brewfile"
if [ -f "${BREWFILE}" ]; then
  echo "==> Installing packages from Brewfile..."
  brew bundle --file="${BREWFILE}"
else
  echo "[!] Brewfile not found: ${BREWFILE}"
  exit 1
fi
