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
│   ├── zsh/
│   │   └── .zshrc
│   ├── vim/
│   │   └── .vimrc
│   ├── git/
│   │   ├── .gitconfig
│   │   └── .gitignore_global
│   ├── editorconfig/
│   │   └── .editorconfig
│   └── claude/.claude/
│       ├── settings.json
│       └── skills/        # Claude Code用スキル定義（d-* prefix）
│           ├── d-persona/     # 人格切替（ルイズ/ゲンドウ）
│           ├── d-magi/        # MAGI判定（3並列エージェント分析）
│           ├── d-plan-create/ # Plan作成
│           ├── d-plan-review/ # Plan確認
│           ├── d-plan-implement/ # Plan実装
│           ├── d-plan-complete/  # Plan完了
│           └── d-plan-resume/    # 作業再開
├── scripts/               # セットアップスクリプト
│   ├── install.sh         # メインエントリ（brew.sh → stow → macos.sh → autoupdate）
│   ├── brew.sh            # Xcode CLT + Homebrew + brew bundle
│   └── macos.sh           # macOSシステム設定（defaults write）
├── desk/                 # ローカル専用（gitignore対象）
│   ├── plans/             # 個人plan管理
│   └── knowledge-base/    # ナレッジベース（git clone ugdark/knowledge-base）
├── Brewfile               # Homebrewパッケージ一覧
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

## skills（d-*）の設計方針

`settings/claude/.claude/skills/` 配下のスキルは **汎用的** に作る。

- **プロダクト・言語に依存しない**: 特定のフレームワーク（sbt, npm等）やレイヤー構造（domain/gateway等）をスキル内にハードコードしない
- **プロジェクト固有の設定はCLAUDE.mdに委任**: フォーマッタ、テストコマンド、レイヤー構成等は各プロジェクトのCLAUDE.mdに記載し、スキルはそれを参照する
- **テンプレートはシンプルに**: planテンプレートには構造だけ置き、具体的な内容はreview時に埋める
