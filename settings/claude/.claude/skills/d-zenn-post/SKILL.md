---
name: d-zenn-post
description: "Zenn記事投稿 - drafts/の下書きを最終確認・プレビューし、公開(articles/へ移動→published:true→commit & push)する。「Zennに投稿して」「記事を公開して」「Zennに上げて」と言われた時に使用する。"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Edit, Bash, AskUserQuestion
argument-hint: "[slug（省略時はdrafts/から選択）]"
---

# Zenn記事投稿

`drafts/` にある下書き（`d-zenn-interview` で作成した本文ドラフト）を、最終確認・プレビューのうえ **公開** する。
これは Zennワークフローの **③投稿** 段階。本文の執筆は `d-zenn-interview`（②）で済んでいる前提で、ここは **投稿作業に専念** する。

## 前提

- Zennの実体は **vault配下の独立したsubmodule**（remote: `ugdark/zenn-articles`、GitHub連携デプロイ）
- 公開の commit & push は **submoduleディレクトリ内**で行う（`.dotfiles` 側のpushでは反映されない）
- node/pnpm のバージョンは `mise.toml` で固定済み。コマンドは zenn ディレクトリ内で実行する
- 作業ディレクトリは常に `~/.dotfiles/vault/articles/zenn`

## 使用場面

- 「Zennに投稿して」「記事を公開して」「Zennに上げて」と言われた時
- `d-zenn-interview` でドラフトを書き終えた後
- `/d-zenn-post [slug]` で手動呼び出し

## 実行フロー

### Step 1: 対象ドラフトの特定とリポジトリ状態確認

以下を**並列**で実行する:

1. Bash: `ls ~/.dotfiles/vault/articles/zenn/drafts/*.md` — 下書き一覧（`_template.md` は除外）
2. Bash: `git -C ~/.dotfiles/vault/articles/zenn status -s` — 未コミットの変更
3. Bash: `git -C ~/.dotfiles/vault/articles/zenn fetch -q origin && git -C ~/.dotfiles/vault/articles/zenn status -sb | head -1` — remoteとの同期状態

- 引数で slug 指定があればそれを対象に。なければ下書き一覧から選んでもらう
- remoteより遅れている場合は「remoteに変更があります。先に `git pull` しますか？」と確認

### Step 2: 公開前の最終確認

Read で対象ドラフトを読み、以下をチェックする:

- `title` `emoji` `type` `topics` が埋まっているか（空なら公開を止めて確認）
- `topics` は最大5個・英小文字推奨
- 本文中に `<!-- 要確認: ... -->` が残っていないか → **残っていれば内容を提示し、解消してから公開する**
- 誤字・リンク切れ・コードブロックの言語指定など、目立つ問題がないか

軽微な修正は Edit で直してよい。大幅な加筆が必要なら「本文の執筆は `d-zenn-interview` に戻ったほうがよい」と案内する。

### Step 3: プレビュー案内

公開前にローカルプレビューを促す（ユーザー自身が `!` で起動するのが確実）:

```bash
cd ~/.dotfiles/vault/articles/zenn && pnpm preview
```

→ ブラウザ（通常 http://localhost:8000 ）で表示を確認してもらう。

### Step 4: 公開

**公開はユーザーの明示的な指示があってから**行う（勝手に公開しない）。

1. `drafts/<slug>.md` を `articles/<slug>.md` へ移動:
   `git -C ~/.dotfiles/vault/articles/zenn mv drafts/<slug>.md articles/<slug>.md`
   （既に `articles/` にある場合はスキップ）
2. frontmatter の `published` を `true` に変更（Edit）
3. submodule内で commit & push:

```bash
git -C ~/.dotfiles/vault/articles/zenn add articles/<slug>.md
git -C ~/.dotfiles/vault/articles/zenn commit -m "Publish: <記事タイトル>"
git -C ~/.dotfiles/vault/articles/zenn push
```

### Step 5: 完了報告

- 公開したファイルパスを表示
- GitHub連携でZennに自動反映される旨と、記事URLの見込み（`https://zenn.dev/<ユーザー>/articles/<slug>`）を伝える

## 重要ルール

- **投稿に専念する**: 本文の執筆・大幅加筆はしない（それは `d-zenn-interview` の役割）。ここは最終確認・プレビュー・公開のみ
- **公開は明示指示があってから**: `published: true` への変更とpushは、ユーザーが「公開して」と言った時だけ実行する
- **commit & push はsubmodule内で**: 必ず `git -C ~/.dotfiles/vault/articles/zenn ...` を使う。`.dotfiles` 側でcommitしてもZennには反映されない
- **要確認コメントを残さない**: `<!-- 要確認 -->` が残ったまま公開しない
- **topicsは英小文字・最大5個**
