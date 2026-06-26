---
name: d-quest-create
description: "Quest作成 - 新規/改修/バグ調査テンプレートを選択してquestファイルを作成"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Glob, AskUserQuestion
argument-hint: "[feature|bugfix|investigation]"
---

# Quest作成

questファイルを新規作成する。テンプレートを選択し、連番を自動管理する。

## 使用場面

Claudeは以下の状況で**自動的にこのスキルを適用**する：

- 「quest作成して」「questを作って」「新しいquestを作成して」と言われた時

また、`/d-quest-create` で手動呼び出しも可能。

## 実行フロー

### Step 1: テンプレート選択（最初に必ず実行）

**引数あり**の場合（`$ARGUMENTS[0]` が `feature` / `bugfix` / `investigation`）:
→ そのテンプレートを使用し、Step 2へ進む

**引数なし**の場合:
→ 以下の AskUserQuestion を**即座に実行**する。他のツール呼び出しやテキスト出力より先に実行すること。

```
AskUserQuestion:
  question: "どのテンプレートでquestを作成しますか？"
  header: "テンプレート"
  options:
    - label: "feature"
      description: "新規機能の追加"
    - label: "bugfix"
      description: "既存機能の改修・修正"
    - label: "investigation"
      description: "バグ調査・原因分析"
```

ユーザーの回答を受け取ってからStep 2へ進む。回答を受け取るまで他のStepに進んではならない。

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

### Step 4: 完了報告

- 作成したファイル名を表示
- 「要望・要件」セクションに内容を記載するよう案内
- **実装開始は促さない**（ユーザーが後でファイル名を変更する前提）

## 重要ルール

- activeとcompletedの**両方**を確認して連番の重複を防ぐ
- テンプレート内容はそのまま書き込む（編集しない）
- questファイル保存先: `~/.dotfiles/vault/quests/`
- テンプレートには末尾に `## やり取り履歴` セクションが含まれる。**d-quest-* 系スキル実行中の質問・回答・議論で出た判断は、このセクションの末尾に時系列で逐次追記する**（先頭に挿入しない／本体セクションの編集とは別に追記のみ）
