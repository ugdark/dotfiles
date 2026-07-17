---
name: d-pr-create
description: "PR作成 - PRテンプレートを読み込み、差分を分析してドラフトPRを作成する。「PR作って」「PRを作成して」「プルリク出して」と言われた時に自動適用する。PRやプルリクエストの作成に関する依頼では必ずこのスキルを使用すること。"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion
argument-hint: "[--no-draft]"
---

# PR作成

PRテンプレートを読み込み、差分を分析してドラフトPRを作成する。

## 使用場面

Claudeは以下の状況で**自動的にこのスキルを適用**する：

- 「PR作って」「PRを作成して」「プルリク出して」と言われた時
- 実装完了後に「PRにして」と言われた時

また、`/d-pr-create` で手動呼び出しも可能。

## 実行フロー

### Step 1: 現在の状態を確認

以下を**並列**で実行する：

1. Bash: `git status` — 未コミットの変更がないか確認
2. Bash: `git log --oneline -10` — 直近のコミット履歴
3. Bash: `git rev-parse --abbrev-ref HEAD` — 現在のブランチ名
4. Bash: `git log $(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)..HEAD --oneline 2>/dev/null` — ベースブランチからの差分コミット

**未コミットの変更がある場合**: 「未コミットの変更があります。先にコミットしますか？」と確認する。

**mainまたはmasterブランチにいる場合**: 「mainブランチにいます。PRを作成するにはfeatureブランチが必要です」と警告して停止する。

### Step 2: PRテンプレートを探す

Glob: `**/pull_request_template.md` でリポジトリ内の全テンプレートを一括検索する（大文字小文字を区別しない）。

複数見つかった場合は、GitHub公式の優先度順で最初の1つを使用する：

1. `.github/pull_request_template.md` — 最優先
2. `pull_request_template.md` — リポジトリルート
3. `docs/pull_request_template.md` — docsディレクトリ

**見つかった場合**: Read でテンプレートを読み込む。
**見つからなかった場合**: デフォルト構造を使用する（Step 3参照）。

### Step 3: 差分を分析してPR本文を作成

1. Bash: `git diff $(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)...HEAD` で全差分を取得
2. 全コミットメッセージと差分を分析
3. PR本文を作成する：

**本文の書き方（テンプレート有無に関わらず適用）**:

- **冒頭に3行の要約を置く**: 本文の最初に、要約として主な修正内容を箇条書き3つ内で書く。
- **全体を短くする**: 本文全体で目安20行以内。箇条書きは1項目1行、各セクション3〜5項目まで。差分を読めば分かる詳細（メソッド名の列挙、実装手順の説明）は書かない
- 書くのは「差分から読み取れないこと」だけ: 背景・意図・レビューで見てほしい点・動作確認方法

**テンプレートがある場合**:
- **冒頭に3行の要約を置く**: 本文の最初に、要約として主な修正内容を箇条書き3つ内で書く。
- チェックリストがある場合、該当する項目のみチェックを入れる

**テンプレートがない場合**:
- 以下のデフォルト構造を使用：

```markdown
- <主な修正内容（箇条書き3つ以内）>

## Changes
<主な変更点を箇条書きで・3〜5項目>

## Test plan
<テスト方法を箇条書きで>
```

### Step 4: PRタイトルを作成

- コミット履歴と差分から簡潔なタイトルを作成（70文字以内）
- Conventional Commits形式を推奨: `feat:`, `fix:`, `refactor:` 等

### Step 5: リモートへpushしてPRを作成

1. Bash: `git push -u origin HEAD` — リモートにpush
2. Bash: PRを作成

```bash
gh pr create \
  --draft \
  --assignee @me \
  --title "タイトル" \
  --body "$(cat <<'EOF'
PR本文
EOF
)"
```

`--no-draft` 引数が指定された場合は `--draft` を省略する。

### Step 6: 完了報告

- 作成したPRのURLを表示
- ドラフトPRであることを明記

## 重要ルール

- **短さ優先**: 冒頭3行要約＋本文20行以内が目安。長い説明はレビュアーに読まれない
- **テンプレートを尊重**: プロジェクトにテンプレートがあれば必ずその構造に従う
- **ドラフトがデフォルト**: `--no-draft` 指定時のみ通常PRにする
- **assigneeは常に付与**: `--assignee @me` を必ず付ける
- **pushする前の確認は不要**: ドラフトPRなので安全
- **CLAUDE.mdの指示を優先**: プロジェクトのCLAUDE.mdにreviewer・label等の指定があればそれに従う
- **個人設定ファイルへの参照を含めない**: PR本文に以下のような個人ローカルにしか存在しないパス・識別子を含めない。レビュアーが追えない情報になるため。
  - `~/.dotfiles/...`, `.desk/quests/...`, `.desk/roadmap/...` 配下のファイルパス
  - 個人 quest の識別子（例: `quest:20260527_03`, `20260527_03_xxx_quest.md`）
  - 個人 vault やローカル note への参照
  - 代わりに、リポジトリ内に commit 済みのファイル（`docs/...` や issue / Asana チケット URL）のみ参照する
