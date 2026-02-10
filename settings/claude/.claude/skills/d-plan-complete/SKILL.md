---
name: d-plan-complete
description: "Plan完了 - チェックボックス確認後、planをcompletedへアーカイブ"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Glob
---

# Plan完了

planをアーカイブ（active → completed へ移動）する。

## 使用場面

Claudeは以下の状況で**自動的にこのスキルを適用**する：

- 「plan完了」「planを完了させて」「アーカイブして」と言われた時

また、`/d-plan-complete` で手動呼び出しも可能。

## 実行フロー

### Step 1: planファイルの読み込み

- Read: 現在作業中のplan.md
- 不明な場合は active/ をGlobで確認

### Step 2: チェックボックス確認

- 「## 対応状況」セクションを確認
- `[x]` の数（完了済み）と `[ ]` の数（未完了）をカウント

**未完了がある場合**:
- 警告メッセージを表示
- 「まだN個のタスクが未完了です：[リスト]。本当に完了しますか？」
- ユーザー確認を待つ
- NGなら停止

### Step 3: 最終確認

- 「本当に完了してアーカイブしますか？」と確認
- ユーザーの明示的なOKを待つ

### Step 4: ファイル移動

- Bash: `mv ~/.dotfiles/local/plans/active/[ファイル名].md ~/.dotfiles/local/plans/completed/`
- ファイル名は変更しない

### Step 5: 完了報告

- 「planをアーカイブしました」
- 移動先のパスを表示

### Step 6: 次のplan確認

- active/ に他のplanがあるか確認
  - Glob: `~/.dotfiles/local/plans/active/*.md`
- ある場合: 「active/[ファイル名].md がありますが、これに進みますか？」
- ない場合: 「新しいplanを作成しますか？」

## 重要ルール

- フォーマット（sbt format）やテスト実行は別途ユーザーが実行する前提
- このスキルは「チェック確認 + ファイル移動」のみ
