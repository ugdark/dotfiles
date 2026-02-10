#!/bin/bash
#
# macOS システム設定
# 変更を反映するには一部ログアウト or 再起動が必要
#
set -eu

echo "==> Configuring macOS defaults..."

# ===========================================================
# Finder
# ===========================================================
# 隠しファイルを表示
defaults write com.apple.finder AppleShowAllFiles -bool true
# 拡張子を常に表示
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# ===========================================================
# Dock
# ===========================================================
# 自動的に隠す
defaults write com.apple.dock autohide -bool true
# 表示/非表示の遅延をなくす
defaults write com.apple.dock autohide-delay -float 0
# アニメーション速度を速く
defaults write com.apple.dock autohide-time-modifier -float 0.3

# ===========================================================
# 反映
# ===========================================================
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "   [ok] macOS defaults configured"
