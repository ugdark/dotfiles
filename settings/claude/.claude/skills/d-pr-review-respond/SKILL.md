---
name: d-pr-review-respond
description: PRのレビュー指摘を拾って plan に反映し、対応後に各指摘へ個別返答する一連のワークフロー。「PRのレビュー指摘対応して」「レビュー拾って」「レビュー返答して」と言われた時に使用する。
---

# PR レビュー指摘対応ワークフロー

PR のインライン review コメントを拾い、現在の plan に「レビュー指摘対応」サブセクションを追加し、対応完了後に各コメントへ個別返答する。

## 使用場面

Claudeは以下の状況で**自動的にこのスキルを適用**する：

- 「PR のレビュー指摘を対応して」「レビュー拾って」「レビュー返答して」と言われた時
- PR レビュー後、修正と返答をまとめて進めたい時

また、`/d-pr-review-respond` で手動呼び出しも可能。

## 前提

- 対象 PR は現在チェックアウト中の feature ブランチに紐づく、または PR 番号がユーザーから指定される
- 対応中の active quest が存在する（`d-quest-create` で作成済）
- `gh` CLI が認証済

## 対象レビュー

- **Copilot / Claude / 人間レビュー** すべて対象（誰のレビューでも拾う）
- 自分の返信は除外する
- `[must]` / `[imo]` / `[nits]` / `[ask]` / `[fyi]` の prefix がついていれば優先度として扱うが、prefix なしでも全件拾う
- **ローカル `d-pre-review` の結果も同じセクションに統合**（外部レビューと自己レビューを一つの対応リストに）

---

## 実行フロー（6ステップ）

### Step 1: PR 特定

1. 現在のブランチから PR を特定（または引数で PR 番号を受け取る）
   ```bash
   gh pr view --json number,title,headRefName
   ```
2. PR 番号が複数候補ある場合は AskUserQuestion で選ばせる

### Step 2: レビューコメント収集

1. inline review コメント一覧を取得
   ```bash
   gh api /repos/{owner}/{repo}/pulls/{PR}/comments
   ```
2. 各コメントを以下の形式でパース:
   - `id`（返信時に in_reply_to で使う）
   - `user.login`
   - `path` + `line` / `original_line`
   - `body`
   - `in_reply_to_id`（既に返信スレッドなら、その元コメント ID）
3. **除外条件**:
   - 自分（`gh api /user` の login）が作成したコメント
   - 既に自分から返信があるスレッド（`in_reply_to_id` で対応済みを判定）
4. 各コメントの本文先頭から prefix（`[must]` 等）を抽出して優先度メモを作る
5. **報告**: 拾った件数とサマリ（path / 抜粋 / prefix）をユーザーに提示

### Step 3: ローカル `d-pre-review` の実行

外部レビューを拾うのと並行して、`/d-pre-review` を起動してローカル差分の自己レビューを実行する。

1. `Skill` ツールで `d-pre-review` を呼び出し
   - 引数なし（= `develop` ベースの差分を対象）
   - PR が複数ある場合は各 PR のブランチ毎に分けて実行
2. 出力（Critical / High / Medium / Low + Good）を取得
3. 「ローカル指摘」として後続 Plan 反映で統合する
4. **既に外部レビューで同じ箇所が指摘されている場合は重複扱いとして 1 件にまとめる**（出所欄に「外部 + ローカル」と併記）

### Step 4: Plan への反映

1. 現在の active quest を Read で読み込み
   - Glob: `~/.dotfiles/vault/quests/active/*.md`
   - 不明なら AskUserQuestion で選ばせる
2. plan ファイル **全体の末尾**（`## やり取り履歴` のさらに後ろ）に新規セクションを追加する
3. 見出しは `## PR レビュー指摘対応（PR #{PR番号}、外部 N件 / ローカル M件）` 形式
   - PR が複数なら `## PR レビュー指摘対応（PR-A #{N} / PR-B #{M}、外部 X件 / ローカル Y件）`
4. 各指摘を以下の形式でチェックボックス化（**出所** で外部 / ローカル を区別）:
   ```markdown
   - [ ] **#{連番}** [{prefix}]: `{path}` {要約}
     - **指摘**: {コメント本文 or d-pre-review の指摘内容}
     - **出所**: 外部（コメントID: {id}） / ローカル（d-pre-review）/ 両方（コメントID: {id} + d-pre-review）
   ```

   **対応見送り（不採用）の場合**:
   - チェックボックスの直後に `❌` を付け、`[ ] ❌` 形式で残す（チェックは入れない）
   - 末尾に `**対応見送りの理由**: {理由}` 行を追加
   - メモリ `feedback_keep_rejected_items.md` に従い、不採用項目も**削除せず履歴として残す**
   ```markdown
   - [ ] ❌ **#{連番}** [{prefix}]: `{path}` {要約}
     - **指摘**: {コメント本文}
     - **出所**: 外部（コメントID: {id}）
     - **対応見送りの理由**: {採用しない判断の根拠 / 採用しても効果が薄い理由 等}
   ```
5. **PR 情報 + ローカルレビュー実行**を plan の「やり取り履歴」末尾にも追記:
   ```markdown
   ### YYYY-MM-DD HH:mm （d-pr-review-respond）
   - PR #{PR番号} レビュー指摘 外部{N}件 / ローカル {M}件を拾い、plan に反映
   - 指摘の概要: ...
   ```
6. **書き込み後に Read で確認する**（必須）
   - Edit/Write ツールで書き込んだ後、必ず plan ファイルを Read して内容が反映されているか確認する
   - 反映されていない場合は再度 Write で書き込む
   - **書き込み内容をチャットに出力しない** — Edit/Write ツールを呼ぶだけでよい。内容をテキストで貼り出すのは禁止

**重要**: Step 2 → Step 3 → Step 4 は **連続して自動実行する**（途中でユーザー確認を取らない）。
レビュー収集・d-pre-review 実行・plan 反映は一つのタスクとして扱い、止まらず Step 4 まで進める。
ユーザー確認は **Step 5（各指摘の対応）から開始** する。

### Step 5: 各指摘の対応（必須停止）

`d-quest-implement` スキルと同じフローで 1 件ずつ進める:

1. 1 件目の指摘を表示し、対応方針を提示
2. ユーザー確認 → OK 後に実装
3. テスト実行で緑確認
4. plan のチェックボックスを更新（`[ ]` → `[x]`）
5. 次の指摘へ

**重要**: ユーザーが「最小限で対応」「却下する」等の方針を出した場合は plan の該当チェックボックスに方針を追記してから進む。

### Step 6: 個別返答 + commit/push

1. 全指摘対応完了後、commit + push
   - **rebase 不要**ならそのまま push
   - **rebase 済**なら `--force-with-lease`
2. **外部レビュー指摘のみ** に inline reply（ローカル指摘は plan 内でクローズ、PR への返信不要）
   ```bash
   gh api -X POST /repos/{owner}/{repo}/pulls/{PR}/comments \
     -f body="対応しました。{対応内容のサマリ}

   commit: {sha}" \
     -F in_reply_to={comment_id}
   ```
3. 却下する指摘は理由を明示して返信:
   ```
   ご指摘の意図は理解できますが、{理由} のため対応を見送ります。
   {代わりに何をしたか}
   ```
4. 全 reply の id を `OK reply: {id}` で確認
5. plan の最終チェックボックス（push 等）を `[x]` 化

## 最重要ルール

- **拾い（外部 + ローカル）→ plan 反映 → 対応 → 返答 の順序厳守**
- **各指摘の対応はユーザーの明示的な OK を受けてから次へ**（`d-quest-implement` と同じ規約）
- **対応見送り（不採用）は `[ ] ❌` マーク + `対応見送りの理由` を必ず書く**（メモリ `feedback_keep_rejected_items.md` 準拠、削除せず履歴保持）
- **却下する場合は plan に「却下」と書く + 理由を返信に含める**
- **`in_reply_to` を必ず使う**（top-level コメントではなくスレッド内に返信）
- **自分の過去の返信を除外**してから plan 反映する（同じスレッドに重複反映しない）
- **ローカル指摘は plan 内でクローズ**（PR への返信は不要、PR コメントを汚さない）
- **重複指摘は 1 件にまとめる**（外部 + ローカルで同じ箇所が指摘された場合）

## 利用 API メモ

```bash
# レビューコメント一覧
gh api /repos/{owner}/{repo}/pulls/{PR}/comments

# 自分の login
gh api /user --jq '.login'

# inline reply（スレッド内返信）
gh api -X POST /repos/{owner}/{repo}/pulls/{PR}/comments \
  -f body="..." \
  -F in_reply_to={comment_id}

# 既存スレッドの解決状態は graphql でしか取れないので、
# 簡易判定は in_reply_to_id があるかで代用してよい
```

## やり取り履歴の追記（必須）

スキル実行中の **対応方針判断・却下理由** は plan 末尾の `## やり取り履歴` セクションに逐次追記する。

- フォーマット例:
  ```markdown
  ### YYYY-MM-DD HH:mm （d-pr-review-respond: 指摘#N 対応）
  - 指摘: {要約}
  - 方針: 採用 / 案A / 案B / 却下
  - 理由: 〜
  ```

## 参考実装ログ

PR #1614 (step02 Restore) で 6 件の Copilot レビューを拾い、案 A / 案 B 判断を経て対応完了したログ:
- `~/.dotfiles/vault/quests/active/20260521_01_生徒一括Excel段階PR_quest.md`
- 「## やり取り履歴」の「2026-05-21 step02 PR #1614 レビュー指摘反映」以降