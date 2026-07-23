---
name: d-guide-knowledges
description: "ナレッジ記述ガイド - knowledge-baseのmd形式を統一。「ナレッジを書いて」「ナレッジを追加して」と言われた時や、knowledge-base配下のmd編集時に使用する。"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob
argument-hint: "[ファイルパス]"
---

# ナレッジ記述ガイド

knowledge-base に記事を書く・編集する際のフォーマットガイド。

## knowledge-base のパス

```
~/.dotfiles/vault/knowledge-base/
```

**注意: knowledge-base は独立したgitリポジトリ**（`ugdark/knowledge-base`、public）であり、vault（`ugdark/dovault` private）にネストしているが別管理。記事の変更後は knowledge-base リポジトリ側でcommit/pushが必要。

## 使用場面

Claudeは以下の状況で**自動的にこのスキルを適用**する：

- `~/.dotfiles/vault/knowledge-base/` 配下のmdファイルを新規作成する時
- `~/.dotfiles/vault/knowledge-base/` 配下のmdファイルを編集する時
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

### Step 4: 関連ファイルの更新

記事の新規作成・削除・タイトル変更を行った場合、以下のファイルも連動して更新する。

- **README.md** (`~/.dotfiles/vault/knowledge-base/README.md`): カテゴリ別の記事一覧
- **_sidebar.md** (`~/.dotfiles/vault/knowledge-base/_sidebar.md`): Docsifyサイドバー用リンク一覧

更新ルール：
- 記事を追加したら、該当カテゴリのセクションにリンクを追加する
- 記事を削除したら、該当リンクを削除する。カテゴリ内の記事が0件になった場合はカテゴリセクションごと削除する
- カテゴリを新規追加した場合はセクションを追加し、スキル内のカテゴリ一覧も更新する
- 既存記事の編集のみ（タイトル変更なし）の場合は更新不要

#### _sidebar.md のNEWマーク運用

Docsifyサイドバー（`_sidebar.md` のみ）では新規追加記事に目印を付ける。`README.md` はカテゴリ別インデックスなのでマーク不要。

- **付与**: 新規追加記事の行頭に `<b>NEW</b>` を付ける

  ```markdown
  - <b>NEW</b> [記事タイトル](category/記事タイトル.md)
  ```

- **除去タイミング**: **次回の新規追加時、既存の `<b>NEW</b>` はすべて外してから** 新規分を付ける。複数本を同時追加した場合は一括でNEW付与OK
- **マーク装飾**: CSSは使わず `<b>` タグで統一する。理由は (1) CSS管理コスト不要、(2) マークダウン太字 `**...**` だとカテゴリ見出しと被る、(3) タグ除去は文字列置換1回で済む

### Step 5: commit/pushの促し

全ての更新が完了したら、ユーザーにknowledge-baseリポジトリのcommitとpushを促す。knowledge-baseはdotfilesとは別リポジトリのため、個別にcommit/pushが必要。

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
| team-management | team-management/ | チーム運営・EM（チームビルディング・ファシリテーション・面接・目標管理） |
| development | development/ | 開発手法・ツール |
| database | database/ | データベース |
| ai-coding-agents | ai-coding-agents/ | AIコーディングエージェント |
| go-lang | go-lang/ | Go言語 |
| claude-code | claude-code/ | Claude Code |
| infrastructure | infrastructure/ | インフラ・クラウド |
| devops | devops/ | DevOps |

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
