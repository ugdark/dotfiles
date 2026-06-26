---
name: d-claude-skill-review
description: "Claude Codeスキル・ルールレビュー - Skills(SKILL.md)やRules(.claude/rules/*.md)の品質チェックと改善提案。「スキルをレビューして」「ルールをチェックして」と言われた時に使用する。スキル作成・修正後のプロアクティブなレビューにも対応。"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Glob, Grep, AskUserQuestion
argument-hint: "[skill名 | rule名 | パス]"
---

# Claude Codeスキル・ルールレビュー

Skills（SKILL.md）とRules（.claude/rules/*.md）の品質をレビューし、改善提案を行う。

## 実行フロー

### Step 1: レビュー対象の特定

引数またはユーザーへの質問でレビュー対象を決定する。

**引数ありの場合:**
- パスが指定されたらそのファイルを直接読む
- skill名が指定されたらGlobで `**/skills/<名前>/SKILL.md` を検索
- rule名が指定されたらGlobで `**/.claude/rules/<名前>*.md` を検索

**引数なしの場合:**
- AskUserQuestionで「どのskillまたはruleをレビューする？」と確認
- 「一覧」と言われたら、Globでskills/rulesを列挙して選択してもらう

### Step 2: タイプ自動判定

読み込んだファイルの特徴からタイプを判定する。

| 判定基準 | Skill | Rule |
|---------|-------|------|
| ファイル名 | `SKILL.md` | 任意の`.md` |
| 配置場所 | `skills/*/` 配下 | `.claude/rules/` 配下 |
| frontmatter | `name`, `description` 必須 | `paths` のみ（任意） |
| 本体 | 手順・ワークフロー | ガイドライン・制約 |

### Step 3: レビュー実行

タイプに応じたレビュー基準を references/ から読み込んで適用する。

- **Skill**: Read このスキルの `references/skill-quality.md` を参照してレビュー
  - Glob で対象スキルの `templates/`, `references/`, `scripts/`, `evals/` の存在を確認し、Progressive Disclosureの実践状況を評価する
- **Rule**: Read このスキルの `references/rule-quality.md` を参照してレビュー

### Step 4: レビュー結果の出力

Read このスキルの `templates/review-output.md` を読み込み、そのフォーマットに従って結果を報告する。
