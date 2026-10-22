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
STOW_PACKAGES=(zsh vim git editorconfig agents claude codex mysql bin mise)

for pkg in "${STOW_PACKAGES[@]}"; do
  if [ -d "${DOTFILES_DIR}/settings/${pkg}" ]; then
    # --no-folding: ディレクトリごと symlink 化（folding）を禁止し、常にファイル単位でリンクする。
    # folding されると ~/.config/mise 等の配下に外部ツールが作るファイルが repo に混入する（public のため漏洩リスク）
    stow -d "${DOTFILES_DIR}/settings" -t "$HOME" --no-folding --adopt "${pkg}"
    echo "   [ok] ${pkg}"
  else
    echo "   [skip] ${pkg} (not found)"
  fi
done

# 5. Claude Code CLI（native installer / 自動更新あり）
echo "==> Installing Claude Code CLI..."
if command -v claude &>/dev/null; then
  echo "   [ok] Claude Code already installed."
else
  curl -fsSL https://claude.ai/install.sh | bash
  echo "   [ok] Claude Code installed."
fi

# 6. Google Cloud SDK（公式インストーラー。Homebrew版はcomponentマネージャーが無効化されており
#    gke-gcloud-auth-plugin 等の追加コンポーネントが入れられないため、公式版に統一）
echo "==> Installing Google Cloud SDK..."
if [ -d "$HOME/google-cloud-sdk" ]; then
  echo "   [ok] Google Cloud SDK already installed."
else
  ARCH="$(uname -m)"
  case "$ARCH" in
    arm64) GCLOUD_ARCH="darwin-arm" ;;
    *)     GCLOUD_ARCH="darwin-x86_64" ;;
  esac
  curl -fsSL -o /tmp/gcloud-sdk.tar.gz \
    "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GCLOUD_ARCH}.tar.gz"
  tar -xzf /tmp/gcloud-sdk.tar.gz -C "$HOME"
  rm -f /tmp/gcloud-sdk.tar.gz
  "$HOME/google-cloud-sdk/install.sh" --quiet --usage-reporting=false --path-update=false --command-completion=false
  "$HOME/google-cloud-sdk/bin/gcloud" components install gke-gcloud-auth-plugin --quiet
  echo "   [ok] Google Cloud SDK installed."
fi

# 7. macOS システム設定
bash "${DOTFILES_DIR}/scripts/macos.sh"

echo "==> Setup complete!"
