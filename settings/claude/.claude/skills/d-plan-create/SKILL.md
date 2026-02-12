---
name: d-plan-create
description: "Plan作成 - 調査/改修/新規テンプレートを選択してplanファイルを作成"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Glob
argument-hint: "[investigation|bugfix|feature]"
---

# Plan作成

planファイルを新規作成する。テンプレートを選択し、連番を自動管理する。

## 使用場面

Claudeは以下の状況で**自動的にこのスキルを適用**する：

- 「plan作成して」「planを作って」「新しいplanを作成して」と言われた時

また、`/d-plan-create` で手動呼び出しも可能。

## 実行フロー

### Step 1: テンプレート選択

`$ARGUMENTS[0]` でテンプレート種別を判定する。

| 引数 | テンプレート | 用途 |
|------|------------|------|
| `investigation` | investigation.md | バグ調査・原因分析 |
| `bugfix` | bugfix.md | 既知の問題の改修 |
| `feature` | feature.md | 新規機能実装 |
| （なし） | ユーザーに選択を聞く | |

引数がない場合はユーザーに以下を確認する：
- 「調査（investigation）、改修（bugfix）、新規（feature）のどれですか？」

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
