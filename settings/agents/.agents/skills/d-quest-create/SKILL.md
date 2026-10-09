---
name: d-quest-create
description: "Quest作成 - 機能追加/issueから/タスクを選択してquestファイルを作成"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Glob, Bash, AskUserQuestion
argument-hint: "[feature|issue|task] または issue番号/URL"
---

# Quest作成

questファイルを新規作成する。テンプレートを選択し、連番を自動管理する。

## 使用場面

Claudeは以下の状況で**自動的にこのスキルを適用**する：

- 「quest作成して」「questを作って」「新しいquestを作成して」と言われた時
- 「このissueのquest作って」とissue番号/URL付きで言われた時

また、`/d-quest-create` で手動呼び出しも可能。

## 実行フロー

### Step 1: テンプレート選択（最初に必ず実行）

**引数がissue番号/URL**の場合（`#123` / `123` / `https://github.com/.../issues/123`）:
→ `issue` テンプレートを使用し、Step 1-A へ

**引数がテンプレート名**の場合（`feature` / `issue` / `task`）:
→ そのテンプレートを使用（`issue` なら Step 1-A へ、それ以外は Step 2 へ）

**引数なし**の場合:
→ 以下の AskUserQuestion を**即座に実行**する。他のツール呼び出しやテキスト出力より先に実行すること。

```
AskUserQuestion:
  question: "どのテンプレートでquestを作成しますか？"
  header: "テンプレート"
  options:
    - label: "feature"
      description: "機能追加"
    - label: "issue"
      description: "issueから作成"
    - label: "task"
      description: "タスク（なんでも）"
```

ユーザーの回答を受け取ってからStep 2へ進む。回答を受け取るまで他のStepに進んではならない。

### Step 1-A: issue内容の取得（issueテンプレートのみ）

1. issue番号/URLが未指定ならユーザーに聞く
2. `gh issue view <番号またはURL> --json number,title,url,body` で取得
3. 取得内容は Step 3 で埋め込む（失敗した場合は空欄のままにし、取得できなかった旨を報告する）

### Step 2: 日付取得と連番計算

1. 今日の日付を取得（yyyyMMdd形式）
2. active questの確認
   - Glob: `~/.dotfiles/vault/quests/active/yyyyMMdd_*.md`
3. completed questの確認
   - Glob: `~/.dotfiles/vault/quests/completed/yyyyMMdd_*.md`
4. 両方の連番を統合し、最大値 + 1 を次の連番とする

### Step 3: テンプレート読み込みとファイル作成

1. テンプレートを読み込む
   - Read: このスキルの `templates/{種別}.md`
2. 新規questファイルを作成
   - Write: `~/.dotfiles/vault/quests/active/yyyyMMdd_NN_仮機能名_quest.md`
   - テンプレートの内容をそのまま書き込む
   - **issueテンプレートのみ**: 「対象issue」のURL・タイトルと「issue内容」に取得した本文を埋める。それ以外のセクションは空のまま

### Step 4: 完了報告

**feature / task の場合**:
- 作成したファイル名を表示
- 「要望・要件」セクションに内容を記載するよう案内
- **実装開始は促さない**（ユーザーが後でファイル名を変更する前提）

**issue の場合**:
- issue内容が要望として既に埋まっているため、ユーザーの記載待ちをせず、そのまま `d-quest-review` を続けて実行する
- 作成したファイル名の表示は review の報告にまとめる

## 重要ルール

- activeとcompletedの**両方**を確認して連番の重複を防ぐ
- テンプレート内容はそのまま書き込む（issueテンプレートのissue転記を除き編集しない）
- questファイル保存先: `~/.dotfiles/vault/quests/`
- テンプレートには末尾に `## やり取り履歴` セクションが含まれる。**d-quest-* 系スキル実行中の質問・回答・議論で出た判断は、このセクションの末尾に時系列で逐次追記する**（先頭に挿入しない／本体セクションの編集とは別に追記のみ）
