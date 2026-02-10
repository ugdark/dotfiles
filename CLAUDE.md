# CLAUDE.md

このファイルはClaude Code (claude.ai/code) がこのリポジトリで作業する際のガイドです。

## 概要

macOS向けの個人dotfilesリポジトリ（owner: ugdark）。GNU Stowでシンボリックリンクを管理し、`git clone` + `install.sh` で環境構築が完了する。

## セットアップコマンド

```bash
git clone https://github.com/ugdark/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/scripts/install.sh
```

## ディレクトリ構成

```
~/.dotfiles/
├── settings/              # stow管理対象（stow -d settings -t $HOME）
│   ├── zsh/.zshrc
│   ├── vim/.vimrc
│   ├── git/
│   │   ├── .gitconfig
│   │   └── .gitignore_global
│   └── claude/.claude/
│       └── skills/        # Claude Code用スキル定義
├── scripts/               # セットアップスクリプト
│   ├── install.sh         # メインエントリ（brew.sh → stow → macos.sh → autoupdate）
│   ├── brew.sh            # Xcode CLT + Homebrew + brew bundle
│   └── macos.sh           # macOSシステム設定（defaults write）
├── local/                 # ローカル専用（gitignore対象）
│   ├── plans/             # 個人plan管理
│   └── knowledges/        # ナレッジベース
├── Brewfile               # Homebrewパッケージ一覧
├── .editorconfig
├── .gitignore
├── CLAUDE.md
└── README.md
```

## 設計上のポイント

- **GNU Stow**: `settings/` 配下の各ディレクトリをパッケージとして `$HOME` にシンボリックリンク
- **環境固有設定の分離**: `*.local` パターン（例: `~/.zshrc.local`）でgitignore。会社設定が混入しない
- **スクリプトは冪等**: `install.sh` は何度実行しても安全
- **既存環境との共存**: `stow --adopt` で既存ファイルを取り込み可能
- **機密ファイル**: SSH鍵等はリポジトリに格納しない
