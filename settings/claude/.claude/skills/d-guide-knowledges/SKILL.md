---
name: d-guide-knowledges
description: "ナレッジ記述ガイド - knowledge-baseのmd形式を統一"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob
argument-hint: "[ファイルパス]"
---

# ナレッジ記述ガイド

knowledge-base に記事を書く・編集する際のフォーマットガイド。

## knowledge-base のパス

```
~/.dotfiles/desk/knowledge-base/
```

## 使用場面

Claudeは以下の状況で**自動的にこのスキルを適用**する：

- `~/.dotfiles/desk/knowledge-base/` 配下のmdファイルを新規作成する時
- `~/.dotfiles/desk/knowledge-base/` 配下のmdファイルを編集する時
- 「ナレッジを書いて」「ナレッジを追加して」と言われた時

また、`/d-guide-knowledges` で手動呼び出しも可能。

## 実行フロー

### Step 1: テンプレート読み込み

- Read: このスキルの `templates/knowledge.md`

### Step 2: 対象の判定

`$ARGUMENTS[0]` でファイルパスが指定された場合：
- 既存ファイルを読み込み、テンプレートに沿って形式を修正する

引数なしの場合：
- テンプレートを表示し、フォーマットルールを案内する

### Step 3: フォーマットルールの適用

以下のルールに従ってナレッジを作成・修正する。

## フォーマットルール

### YAMLフロントマター（必須）

```yaml
---
title: "記事タイトル"
category: "カテゴリ名"
tags: [tag1, tag2]
created: 2026-01-15
updated: 2026-02-12
---
```

| フィールド | 必須 | 説明 |
|-----------|------|------|
| title | 必須 | 記事タイトル。h1と同じ内容 |
| category | 必須 | 所属カテゴリ（ディレクトリ名と一致） |
| tags | 必須 | 関連タグ。3-5個目安 |
| created | 必須 | 作成日（ISO 8601: YYYY-MM-DD） |
| updated | 必須 | 最終更新日 |

### カテゴリ一覧

| category値 | ディレクトリ | 内容 |
|-----------|------------|------|
| authentication | authentication/ | 認証技術 |
| scrum | scrum/ | スクラム |
| development | development/ | 開発手法・ツール |
| claude-code | claude-code/ | Claude Code |
| devops | devops/ | DevOps |
| troubleshooting | troubleshooting/ | トラブルシュート |

新カテゴリが必要な場合はディレクトリを追加し、この一覧も更新する。

### 本文構成

```markdown
# タイトル（フロントマターのtitleと同じ）

## 概要
1-2行の要約。この記事が何を扱い、読者が何を得られるか。

---

## 本文セクション
（h2, h3 で構成。セクション番号は任意）

## 参考リンク
- [リンク名](URL)
```

### ルール

- **h1**: 1ファイルに1つだけ。フロントマターの title と一致させる
- **概要**: 必須。`---` 区切り線の前に配置
- **参考リンク**: ある場合は末尾に `## 参考リンク` セクションとしてまとめる
- **セクション番号**: 長い記事（5セクション以上）では番号付きを推奨
- **ファイル名**: 日本語OK。内容が分かる名前をつける
- **画像**: `images/` ディレクトリに配置し、相対パスで参照
