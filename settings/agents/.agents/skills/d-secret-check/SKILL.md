---
name: d-secret-check
description: "機密情報commitチェック - staged差分やリポジトリ全体を走査し、秘密情報・業務固有情報の混入を検出する。「機密チェック」「シークレット確認」「commit前に見て」と言われた時に使用する。"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Edit, Write
argument-hint: "[staged（既定）| all（作業ツリー全体）]"
---

# 機密情報commitチェック

`.dotfiles` 等に個人情報・業務情報・秘密情報がうっかりcommitされるのを防ぐ、手動チェック層。
Claude Code の `PreToolUse` フック（自動ガード）と同じ検出ロジック（`secret-guard.sh`）を手動で走らせる。

## 使用場面

- 「機密チェックして」「シークレット確認」「commit前に見て」と言われた時
- `/d-secret-check` で手動呼び出し

## 多層防御での位置づけ

| 層 | 役割 | 守れる範囲 |
|---|---|---|
| **このskill（手動）** | 意識した時の確認 | 自分が実行した時 |
| **Claude hook（PreToolUse）** | Claude操作の自動ガード | Claude経由のcommit |
| **git pre-commit（任意で導入）** | 人手commitの防壁 | Fork/ターミナル/IDE 全部 |

検出ロジックは3層とも `~/.claude/hooks/secret-guard.sh` を共有する。パターンは
`~/.claude/hooks/secret-patterns.txt`（汎用・git管理）と `secret-denylist.local`（業務語・gitignore）。

## 実行フロー

### Step 1: 対象範囲の判定

- 引数 `all` → 作業ツリー全体（未staged含む）を対象に一時的に全ファイルをstage相当で走査
- 引数なし / `staged` → staged差分のみ（既定）

### Step 2: スキャン実行

staged のみの場合:

```bash
cd <対象リポジトリ> && SECRET_GUARD_DENYLIST=~/.claude/hooks/secret-denylist.local \
  bash ~/.claude/hooks/secret-guard.sh </dev/null; echo "exit=$?"
```

- `exit=0` → 検出なし（クリーン）
- `exit=1` → 検出あり（stderrに該当行が出る）

作業ツリー全体（`all`）の場合は、`git add -A -n` 相当ではなく、明示的に対象ファイルを
`git diff --cached` に載せられないため、`grep -E -i -f` でパターンファイルを直接
全ファイルに当てる（`.git` と gitignore対象は除外）。

### Step 3: 結果報告

- 検出なし: 「クリーンよ。機密は見つからなかったわ」と報告
- 検出あり: 該当ファイル・行を提示し、対処（値の除去 / `.local`化 / gitignore追加）を提案する
  - 誤検出（テストデータ等）なら `secret-patterns.txt` の調整、または業務語の `secret-denylist.local` 追加を促す

## 注意事項

- **検出＝正義ではない**: 誤検出（サンプルキー・テストデータ）はあり得る。機械的にブロックせず理由を添えて提案する
- **業務語リストの置き場所**: `secret-denylist.local` は必ず gitignore 対象（`*.local`）。ここに書く語自体が機密になり得るため、絶対にgit管理下に置かない
- パターンの実体・テストは `~/.dotfiles/settings/claude/.claude/hooks/` を参照
