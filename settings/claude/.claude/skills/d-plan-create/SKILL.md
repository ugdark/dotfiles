---
name: d-plan-create
description: "Plan作成 - 新規/改修/バグ調査テンプレートを選択してplanファイルを作成"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Glob, AskUserQuestion
argument-hint: "[feature|bugfix|investigation]"
---

# Plan作成

planファイルを新規作成する。テンプレートを選択し、連番を自動管理する。

## 使用場面

Claudeは以下の状況で**自動的にこのスキルを適用**する：

- 「plan作成して」「planを作って」「新しいplanを作成して」と言われた時

また、`/d-plan-create` で手動呼び出しも可能。

## 実行フロー

### Step 1: テンプレート選択（最初に必ず実行）

**引数あり**の場合（`$ARGUMENTS[0]` が `feature` / `bugfix` / `investigation`）:
→ そのテンプレートを使用し、Step 2へ進む

**引数なし**の場合:
→ 以下の AskUserQuestion を**即座に実行**する。他のツール呼び出しやテキスト出力より先に実行すること。

```
AskUserQuestion:
  question: "どのテンプレートでplanを作成しますか？"
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
2. active planの確認
   - Glob: `~/.dotfiles/desk/plans/active/yyyyMMdd_*.md`
3. completed planの確認
   - Glob: `~/.dotfiles/desk/plans/completed/yyyyMMdd_*.md`
4. 両方の連番を統合し、最大値 + 1 を次の連番とする

### Step 3: テンプレート読み込みとファイル作成

1. テンプレートを読み込む
   - Read: このスキルの `templates/{種別}.md`
2. 新規planファイルを作成
   - Write: `~/.dotfiles/desk/plans/active/yyyyMMdd_NN_仮機能名_plan.md`
   - テンプレートの内容をそのまま書き込む

### Step 4: 完了報告

- 作成したファイル名を表示
- 「要望・要件」セクションに内容を記載するよう案内
- **実装開始は促さない**（ユーザーが後でファイル名を変更する前提）

## 重要ルール

- activeとcompletedの**両方**を確認して連番の重複を防ぐ
- テンプレート内容はそのまま書き込む（編集しない）
- planファイル保存先: `~/.dotfiles/desk/plans/`
