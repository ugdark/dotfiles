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
- Oh My Zsh のインストール
- Stow によるシンボリックリンク作成（zsh, vim, git, editorconfig, agents, claude, codex, mysql, bin）
- macOS システム設定の適用

## ディレクトリ構成

```
~/.dotfiles/
├── settings/              # stow管理対象（stow -d settings -t $HOME）
│   ├── zsh/
│   │   └── .zshrc
│   ├── vim/
│   │   └── .vimrc
│   ├── git/
│   │   ├── .gitconfig
│   │   └── .gitignore_global
│   ├── editorconfig/
│   │   └── .editorconfig
│   ├── mysql/
│   │   └── .my.cnf        # mysql CLI 共通設定（接続情報は含まない）
│   ├── agents/.agents/    # ★実体マスター（Claude/Codex共通）→ ~/.agents/
│   │   ├── AGENTS.md      # 共通グローバル指示の実体
│   │   └── skills/        # 全 d-* スキルの実体。個別の説明は各 skills/*/SKILL.md の description を参照
│   ├── claude/.claude/
│   │   ├── CLAUDE.md      # Claude用グローバル指示。先頭で @~/.agents/AGENTS.md を import し共通指示を集約
│   │   ├── settings.json
│   │   └── skills/        # → settings/agents/.agents/skills へのsymlink（マスターを参照）
│   ├── codex/.codex/
│   │   ├── AGENTS.md      # → settings/agents/.agents/AGENTS.md へのsymlink（~/.codex/AGENTS.md が解決）
│   │   └── config.toml    # Codex自動生成・gitignore対象（機密混入防止）
│   └── bin/.local/bin/    # ~/.local/bin に配置するユーザースクリプト
│       └── db-query       # Sequel Ace連携 MySQL ラッパー（d-sql skill用）
├── scripts/               # セットアップスクリプト
│   ├── install.sh         # メインエントリ（brew.sh → OMZ → stow → macos.sh → autoupdate）
│   ├── brew.sh            # Xcode CLT + Homebrew + brew bundle
│   └── macos.sh           # macOSシステム設定（defaults write）
├── vault/                 # ローカル専用（gitignore対象 / 別repo: ugdark/dovault, private）
│   ├── quests/            # 個人quest管理
│   ├── daily/, weekly/    # Obsidianノート
│   ├── .obsidian/         # Obsidian設定
│   └── knowledge-base/    # ナレッジベース（submodule: ugdark/knowledge-base, public）
├── Brewfile               # Homebrewパッケージ一覧
├── .gitignore
├── CLAUDE.md              # Claude Code用プロジェクト指示
└── README.md
```

## 設計上のポイント

- **GNU Stow**: `settings/` 配下の各ディレクトリをパッケージとして `$HOME` にシンボリックリンク
- **環境固有設定の分離**: `*.local` パターン（例: `~/.zshrc.local`）でgitignore。会社設定が混入しない
- **スクリプトは冪等**: `install.sh` は何度実行しても安全
- **既存環境との共存**: `stow --adopt` で既存ファイルを取り込み可能
- **機密ファイル**: SSH鍵等はリポジトリに格納しない
- **AIエージェント設定の共通化**: 共通指示（AGENTS.md）と全 `d-*` スキルの実体は `settings/agents/.agents/` に一元化。Claude は `~/.claude/CLAUDE.md` の `@~/.agents/AGENTS.md` import と `skills` symlink で、Codex は `~/.codex/AGENTS.md` symlink と `~/.agents/skills` 直読みで、同じマスターを参照（二重管理ゼロ）

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

## プロジェクトでのplan利用

各プロジェクトで `dotdesk` を実行すると、dotfilesの `vault/`（plans, knowledge-base等）へのシンボリックリンクが作成されます。

```bash
cd ~/Works/my-project
dotdesk    # .desk → ~/.dotfiles/vault/ のシンボリックリンクを作成
```

`.desk/` は `.gitignore_global` で無視されるため、プロジェクト側の git に影響しません。

## vault/ のセットアップ

`vault/` はdotfilesから見るとgitignore対象で、別repoとして管理しています（`ugdark/dovault`, private）。
内部の `knowledge-base/` はさらにsubmoduleとして `ugdark/knowledge-base`（public）を参照します。

```bash
# vault本体（knowledge-baseを含めて再帰clone）
git clone --recurse-submodules git@github.com:ugdark/dovault.git ~/.dotfiles/vault

# 既にcloneしてから submoduleを取得し直す場合
cd ~/.dotfiles/vault && git submodule update --init --recursive
```

**なぜ vault/ を ~/.dotfiles 配下に置くのか：**
- vault配下なら Claude Code のグローバル権限（`~/.dotfiles/**`）でカバーされる
- 外部パスへのシンボリックリンクだと、プロジェクトごとに書き込み承認が必要になる
- settings.json にローカル固有のパスを書かずに済む（dotfiles は public リポジトリ）

## 環境固有の設定

会社やマシン固有の設定は `~/.zshrc.local` に記述してください。
このファイルは `.zshrc` から自動で読み込まれ、gitignore されています。

```bash
# ~/.zshrc.local の例
export GITHUB_TOKEN="xxx"
export AWS_DEFAULT_PROFILE="my-profile"
```
