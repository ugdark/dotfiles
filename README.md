# dotfiles

macOS 環境のセットアップを自動化する dotfiles リポジトリ。

GNU Stow でシンボリックリンクを管理し、`git clone` + `install.sh` で環境構築が完了します。

## セットアップ

```bash
# 1. リポジトリをクローン
git clone https://github.com/ugdark/dotfiles.git ~/.dotfiles

# 2. インストール実行
bash ~/.dotfiles/scripts/install.sh
```

これだけで以下が完了します：

- Homebrew のインストール（未インストールの場合）
- Brewfile に基づくパッケージ一括インストール
- Stow によるシンボリックリンク作成（zsh, vim, git, mysql）

## ディレクトリ構成

```
~/.dotfiles/
├── settings/          # stow 管理対象（-d settings -t $HOME）
│   ├── zsh/.zshrc
│   ├── vim/.vimrc
│   ├── git/
│   │   ├── .gitconfig
│   │   └── .gitignore_global
│   ├── editorconfig/.editorconfig
│   └── claude/.claude/skills/
├── scripts/           # セットアップスクリプト
│   ├── install.sh     # メインエントリ
│   ├── brew.sh        # Homebrew セットアップ
│   └── macos.sh       # macOS システム設定
├── local/             # ローカル専用（gitignore）
│   ├── plans/         # 作業計画
│   └── knowledges/    # ナレッジベース
├── Brewfile           # Homebrew パッケージ一覧
├── CLAUDE.md          # Claude Code 用プロジェクト設定
└── README.md
```

## Stow の使い方

```bash
# 全パッケージをリンク
stow -d ~/.dotfiles/settings -t $HOME */

# 個別にリンク
stow -d ~/.dotfiles/settings -t $HOME zsh

# リンク解除
stow -d ~/.dotfiles/settings -t $HOME -D zsh

# 既存ファイルを取り込んでリンク化
stow -d ~/.dotfiles/settings -t $HOME --adopt zsh
```

## Homebrew の管理

```bash
# パッケージの手動更新
brew update && brew upgrade

# 自動更新の有効化（バックグラウンドで定期実行）
brew autoupdate start --upgrade --cleanup

# 自動更新の状態確認
brew autoupdate status

# 自動更新の停止
brew autoupdate stop

# Brewfile にないパッケージを確認
brew bundle cleanup --file=~/.dotfiles/Brewfile

# Brewfile にないパッケージを削除（確認後に実行）
brew bundle cleanup --file=~/.dotfiles/Brewfile --force
```

## 環境固有の設定

会社やマシン固有の設定は `~/.zshrc.local` に記述してください。
このファイルは `.zshrc` から自動で読み込まれ、gitignore されています。

```bash
# ~/.zshrc.local の例
export GITHUB_TOKEN="xxx"
export AWS_DEFAULT_PROFILE="my-profile"
```
