---
name: d-pre-review
description: "ローカルコードレビュー - PR作成前のコード品質チェック。「レビューして」「コードチェックして」と言われた時、または /d-pre-review で手動呼び出し時に使用する。プロジェクト版 pre-review の個人ワークフロー版（プロジェクト非依存）。"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Glob, Grep, Bash
argument-hint: "[base branch | PR番号 | --staged]"
---

# ローカルコードレビュー（個人版・プロジェクト非依存）

PR を作成する前に、ローカルでコードレビューを実施する個人ワークフロー版。
**プロジェクト固有の規約は本 skill に書かない**（`.claude/rules/` / CLAUDE.md / プロジェクト版 `/pre-review` 側に任せる）。

## 使用場面

- 「レビューして」「コードチェックして」「事前レビュー」と言われた時
- PR 作成前（`/d-pr-create` 起動前のチェックとして自動連動可）
- 「`/d-pre-review`」で手動呼び出し

## 実行フロー

### Step 1: プロジェクト版 `/pre-review` の有無を確認

1. プロジェクトに `.claude/skills/pre-review/SKILL.md` があれば **そちらを優先**して内容を読み込み、本 skill の汎用フローと統合する
2. 無ければ本 skill の汎用フロー（Step 2 以降）のみで実施

### Step 2: rules / skills 精読（重要）

`.claude/rules/*.md` は auto-load されるが、実装中に見落とすことが多い。レビュー本体に入る前に **再精読**して規約を Step 4 のチェック観点として明示化する。

1. プロジェクトの `.claude/rules/*.md` を再精読（auto-load 済でも明示的に Read）
2. 変更内容に該当する `/guide-*` skill があればそれも読み込む（プロジェクトで定義されている範囲で）
3. CLAUDE.md でプロジェクト固有の規約を確認
4. **報告**: 「読み込んだ rules / skills: ...」を最初の出力に含める

### Step 3: レビュー対象の特定

引数で対象を切り替える。引数なしの場合は `develop` ベース。

| 引数 | 動作 |
|---|---|
| なし | `git diff develop...HEAD` を対象 |
| ブランチ名 | `git diff <branch>...HEAD` を対象 |
| PR 番号 | `gh pr view <N> --json baseRefName` で base 取得 → 差分対象 |
| `--staged` | `git diff --staged` のみを対象 |

1. ベースブランチ特定
   ```bash
   gh pr view --json baseRefName,headRefName 2>/dev/null
   # PR 無ければ develop を base
   ```
2. 差分取得
   ```bash
   git diff <base>...HEAD --stat
   git diff <base>...HEAD
   ```
3. 変更ファイル数 + 追加/削除行数を最初に表示

### Step 3: カテゴリ別レビュー

優先度順に以下を確認する。**該当なしのカテゴリは「該当なし」と明示**し、報告で漏れているのか判定済みなのかを区別できるようにする。

#### 3.1 セキュリティ（Critical / High）
- インジェクション（SQL / コマンド / テンプレート）
- XSS / CSRF / 認証認可の漏れ
- 機密情報のハードコード（パスワード・トークン・シークレット）
- 入力検証の不足

#### 3.2 設計パターン準拠（High / Medium）
- CLAUDE.md / `.claude/rules/` 準拠（プロジェクト固有規約はここに依拠）
- プロジェクト版 `/pre-review` / `/guide-*` skill が定義する規約準拠

#### 3.3 テストカバレッジ（High）
- 新規ロジックに対応するテストが存在するか
- テストパターンがプロジェクト規約に従っているか

#### 3.4 後方互換性（Medium）
- 公開インターフェースの破壊的変更
- DB マイグレーションの互換性

#### 3.5 パフォーマンス（Medium）
- N+1 / 不要な逐次処理 / 不要なデータ取得

#### 3.6 コード品質（Low）
- 未使用 import / 変数 / メソッド
- デバッグコード残置（println / console.log 等）
- TODO コメント残置
- **why コメントの有無**: 非自明な選定・外部仕様依存・既存パターンと異なるアプローチに理由が書かれているか

### Step 4: レビュー結果の報告

```markdown
## コードレビュー結果

**対象**: {base}...HEAD
**変更ファイル**: X files (+YY, -ZZ)

### Critical（即修正）
- [ ] `path` 内容

### High（マージ前修正推奨）
- [ ] `path` 内容

### Medium（改善推奨）
- [ ] `path` 内容

### Low（任意）
- [ ] `path` 内容

---
**総合判定**: ✅ LGTM / ⚠️ 要修正 / ❌ ブロッカーあり
```

- ファイル参照は **行番号を付けない、ファイルパスのみ**（既存メモリ `feedback_file_line_refs.md` に従う）
- 重要度ごとに該当なしなら「該当なし」と明示
- **Good（良い実装）セクションは出力しない**（修正対応に集中、メモリ `feedback_no_good_review.md` 準拠）

### Step 5: ユーザー確認

- 報告後、ユーザーが修正方針を判断
- 「修正しますか？」と聞く
- OK なら修正実施（修正は 1 件ずつ、`d-quest-implement` と同じ確認フロー）

## 重要なルール

1. **差分のみレビュー**: 変更されていないファイルは対象外
2. **プロジェクト固有規約は本 skill に書かない**: CLAUDE.md / `.claude/rules/` / プロジェクト版 `/pre-review` に依拠する
3. **具体的な指摘**: ファイルパスは必ず付ける（行番号は付けない）
4. **過度な指摘は避ける**: 既存コードのスタイルに合わない微細な指摘は避ける
5. **質問と指示の区別**: ユーザーから質問されたら説明で返す（コード変更しない）

## プロジェクト版 `/pre-review` との関係

- 本 skill（個人版）は **汎用ワークフローのみ**を提供
- プロジェクト固有の規約・チェック観点はプロジェクト版 `/pre-review` 側に置く
- 両方ある場合はプロジェクト版を優先（Step 1 参照）