---
name: d-pre-review
description: "ローカルコードレビュー - PR作成前のコード品質チェック。「レビューして」「コードチェックして」と言われた時、または /d-pre-review で手動呼び出し時に使用する。プロジェクト版 pre-review の個人カスタマイズ版。"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Glob, Grep, Bash
argument-hint: "[base branch | PR番号 | --staged]"
---

# ローカルコードレビュー（個人版）

PR を作成する前に、ローカルでコードレビューを実施する。プロジェクト共通の `/pre-review` を個人ワークフロー向けに最適化した版。

## 使用場面

- 「レビューして」「コードチェックして」「事前レビュー」と言われた時
- PR 作成前（`/d-pr-create` 起動前のチェックとして自動連動可）
- 「`/d-pre-review`」で手動呼び出し

## 実行フロー

### Step 1: レビュー対象の特定

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

### Step 2: カテゴリ別レビュー

優先度順に以下を確認する。**該当なしのカテゴリは「該当なし」と明示** し、報告で漏れているのか判定済みなのかを区別できるようにする。

#### 2.1 セキュリティ（Critical / High）
- SQL インジェクション: `s"...$var..."` / `#$variable` が SQL 内で使われていないか
- XSS: ユーザー入力の未サニタイズ出力
- 認証/認可: `authValidUserCookie` が適切に設定されているか
- 機密情報のハードコード（パスワード・トークン・シークレット）
- ヘッダーインジェクション: 外部入力を HTTP ヘッダーに直接使用していないか

#### 2.2 設計パターン準拠（High / Medium）
- **CLAUDE.md / .claude/rules/** 準拠
  - メソッド 10 行以内分割（UseCase 業務フローは除外、`.claude/rules/development-rules.md` 参照）
  - `private[package]` アクセス修飾子
  - ワイルドカード import 禁止
  - 変数命名規則（略さない・複数形ルール・ドメイン名称順序、`.claude/rules/naming-conventions.md` 参照）
  - YAGNI 原則・三回ルール
- **層別ガイド** 準拠
  - Controller → `/guide-controller`（ControllerNewBase / AMInjectModules / 7段階 routes / JSON 変換分離）
  - Query → `/guide-query`（Plain SQL / SlickAMDatabaseAware / am-domain 非依存 / executeシグネチャ統一）
  - UseCase → `/guide-usecase`（UseCaseBase / TransactionHolder / Validator 内製）
  - Domain → `/guide-domain` `/guide-domain-validator`（Entity / VO / Validator / Fixture）
  - Client → `/guide-client`

#### 2.3 テストカバレッジ（High）
- 新規 Controller → ControllerTest
- 新規 Query → QueryImplTest
- 新規 Validator → ValidatorTest
- 新規 Domain → DomainTest
- Given/When/Then パターン（日本語意図）
- `UnitSpecNonMonadError` ベースか（`UnitSpec` は非推奨、`.claude/rules/testing.md` 参照）
- seed 系 Fixture の戻り値は名前付きエイリアス（`school1` 等）を優先（`.head` / `.find` 等のインデックスアクセスを避ける）

#### 2.4 後方互換性（Medium）
- API レスポンスのフィールド削除 / 名前変更
- 既存 public インターフェースの変更
- DB マイグレーションの互換性（Flyway バージョン付き SQL の既存ファイル改変は NG）

#### 2.5 パフォーマンス（Medium）
- N+1 クエリ
- 並列可能 Future の直列実行
- 不要なデータ取得（カラム / 行）

#### 2.6 コード品質（Low）
- 未使用 import / 変数 / メソッド
- デバッグコード（println 等）
- TODO コメント残置
- **why コメントの有無**: 以下のケースで「なぜこの方式か」が書かれているか
  - ID 生成方式の選定（UUID v3/v5/v7、決定的生成 等）
  - 外部仕様依存（API 仕様、RFC 準拠 等）
  - 既存パターンと異なるアプローチ
- 配列アクセスは `(0)` ではなく `.head`（既存ルール）

### Step 3: レビュー結果の報告

```markdown
## コードレビュー結果

**対象**: {base}...HEAD
**変更ファイル**: X files (+YY, -ZZ)

### Critical（即修正）
- [ ] `path:line` 内容

### High（マージ前修正推奨）
- [ ] `path:line` 内容

### Medium（改善推奨）
- [ ] `path:line` 内容

### Low（任意）
- [ ] `path:line` 内容

---
**総合判定**: ✅ LGTM / ⚠️ 要修正 / ❌ ブロッカーあり
```

- ファイル参照は **行番号を付けない、ファイルパスのみ**（既存メモリ `feedback_file_line_refs.md` に従う）
- 重要度ごとに該当なしなら「該当なし」と明示
- **Good（良い実装）セクションは出力しない**（修正対応に集中、メモリ `feedback_no_good_review.md` 準拠）

### Step 4: ユーザー確認

- 報告後、ユーザーが修正方針を判断
- 「修正しますか？」と聞く
- OK なら修正実施（修正は 1 件ずつ、`d-plan-implement` と同じ確認フロー）

## 重要なルール

1. **差分のみレビュー**: 変更されていないファイルは対象外
2. **具体的な指摘**: ファイルパスは必ず付ける（行番号は付けない）
3. **Good 指摘も含める**: 良い実装は積極的に評価
4. **過度な指摘は避ける**: 既存コードのスタイルに合わない微細な指摘は避ける
5. **プロジェクト規約最優先**: CLAUDE.md / .claude/rules/ / 各種 guide-* スキルを最優先でチェック
6. **質問と指示の区別**: ユーザーから質問されたら説明で返す（コード変更しない）

## プロジェクト版 `/pre-review` との違い

- フロントマターを `d-` 系スタイルに揃え、引数指定での対象切替（PR 番号 / `--staged` 等）を明示
- ファイル参照は「パスのみ」のルールを反映
- 各層ガイドスキル（`/guide-*`）への参照を明記してチェック観点を辿りやすく
- 重要度カテゴリで「該当なし」を明示するルールを追加