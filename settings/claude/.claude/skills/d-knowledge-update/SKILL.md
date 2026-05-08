---
name: d-knowledge-update
description: "ナレッジ最新化 - knowledge-baseの記事を最新情報で更新し、新規記事を提案する。「ナレッジを更新して」「ナレッジを最新化して」と言われた時に使用する。"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebSearch, WebFetch, Agent, AskUserQuestion
argument-hint: "[カテゴリ名]"
---

# ナレッジ最新化

knowledge-base の記事を最新情報で更新し、新しいトピックがあれば記事を追加する。

## knowledge-base のパス

```
~/.dotfiles/vault/knowledge-base/
```

**注意: knowledge-base は独立したgitリポジトリ**（`ugdark/knowledge-base`）

## 使用場面

Claudeは以下の状況で**自動的にこのスキルを適用**する：

- 「ナレッジを更新して」「ナレッジを最新化して」と言われた時

また、`/d-knowledge-update` で手動呼び出しも可能。

## 実行フロー

### Step 1: 対象カテゴリの決定

**引数あり**の場合: 指定カテゴリのみ対象
**引数なし**の場合: 全カテゴリを対象

### Step 2: 既存記事の棚卸し

1. 対象カテゴリの記事一覧を取得
   - Glob: `~/.dotfiles/vault/knowledge-base/{カテゴリ}/*.md`
2. 各記事のフロントマターから `updated` 日付を取得
3. 古い順にソートし、一覧を表示

### Step 3: 最新情報の調査

カテゴリごとに最新動向をWebSearchで調査する。

調査観点:
- 既存記事の内容に影響する**破壊的変更・非推奨化・新機能**
- 既存記事にない**新しいトピック**

カテゴリ別の調査キーワード例:
- `claude-code`: "Claude Code changelog", "Claude Code new features 2026", "Anthropic Claude Code update"
- `infrastructure`: "AWS new services", "Kubernetes latest", "Terraform OpenTofu update"
- `authentication`: "OAuth OIDC latest changes"
- `scrum`: 更新頻度低のため基本スキップ
- `development`: 対象ツールの最新バージョン・変更点
- `devops`: 対象ツールの最新バージョン・変更点

### Step 4: 更新計画の提示

調査結果をもとに、以下を一覧で報告する:

```
## 更新計画

### 更新が必要な記事
- [記事名] — 理由: ○○が変更された
- [記事名] — 理由: 新機能○○が追加された

### 新規記事の提案
- [提案タイトル] — 理由: ○○が新しいトピックとして重要

### 更新不要
- [記事名] — 最新の状態
```

**ユーザーの確認を待つ。** 勝手に更新しない。

### Step 5: 記事の更新・作成

ユーザーが承認した項目のみ実行する。

更新時のルール:
- `d-guide-knowledges` のフォーマットに従う
- `updated` 日付を更新する
- 既存の構成を維持しつつ、差分のみ追記・修正
- 出典（参考リンク）を必ず追加

新規作成時:
- `d-guide-knowledges` のテンプレートに従う
- README.md と _sidebar.md も更新する

### Step 6: フォーマットチェック

更新・作成した全記事に対して `/d-guide-knowledges [ファイルパス]` を実行し、フォーマットを統一する。

### Step 7: commit/push

全ての更新が完了したら:
1. knowledge-baseリポジトリでcommit/push
2. dotfilesリポジトリに変更があればそちらもcommit/push

## 重要ルール

- **勝手に更新しない** — 必ずStep 4で計画を提示し、ユーザー確認後に実行
- **出典を明記する** — WebSearchの結果には参考リンクを添える
- **既存の構成を壊さない** — 差分更新を基本とする
- **最後に必ず `d-guide-knowledges` でフォーマットチェックする**