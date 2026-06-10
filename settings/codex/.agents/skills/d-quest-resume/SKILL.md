---
name: d-quest-resume
description: "Quest読み込み・作業再開。active questの進捗を読み、完了済み/残りタスク/次タスク候補を整理する。「quest読み込んで」「作業再開」「続きをやりたい」と言われた時に使う。"
---

# d-quest-resume

questを読み込み、作業状況を把握して次のタスク候補を提示する。
旧`d-plan-resume`のquest版として扱う。

## 参照する設計ソース

必要に応じて、以下を読んで運用思想を確認する。

- `.desk/articles/zenn/articles/dotdesk-plan-cross-repo.md`
- `.desk/articles/zenn/articles/claude-code-personal-skills.md`
- `settings/claude/.claude/skills/d-quest-resume/SKILL.md`
- `settings/claude/.claude/skills/d-quest-implement/SKILL.md`

## questの探索順

ユーザーがquestファイルを明示していない場合、以下の順で探す。

1. `.desk/quests/active/*.md`
2. `vault/quests/active/*.md`
3. `~/.dotfiles/vault/quests/active/*.md`

active questが1件だけなら、そのquestを読む。
複数ある場合は、更新日またはファイル名降順で候補を表示し、ユーザーに選んでもらう。
ユーザーがキーワードやファイル名を指定した場合は、activeを優先して部分一致検索する。見つからなければcompletedも探す。

## 読み取るセクション

questファイルでは、主に以下のセクションを読む。

- `## 要望・要件`
- `## ブランチ名`
- `## 対応状況`
- `## 概要`
- `## 完了条件`
- `## 調査ログ`
- `## 実装メモ`
- `## やり取り履歴`

進捗は`## 対応状況`セクション内のチェックボックスだけで判断する。
ファイル全体のチェックボックスを雑に数えない。

## 報告フォーマット

questを読み込んだら、以下の形で簡潔に報告する。

```text
現在のquestを確認しました。

【Quest】: path/to/quest.md
【概要】: ...
【進捗】: 完了N / 全体M

【完了済み】
- [x] ...

【残りタスク】
- [ ] ...

【最後の実装メモ】
...

【次のタスク候補】
- [ ] ...
```

最後に、次へ進むかどうかをユーザーに確認する。
読み込みだけを依頼された場合は、勝手に実装を始めない。

## 実装へ進む場合

ユーザーが「次へ」「このタスクを進めて」と明示した場合だけ、1つのチェックボックスを対象に実装する。

実装時の順序:

1. questの`要望・要件`、`概要`、`完了条件`、対象チェックボックスを再確認する。
2. 対象プロジェクトの`AGENTS.md`や`CLAUDE.md`があれば読む。
3. 1つのチェックボックスに対応する最小範囲だけ実装する。
4. 必要なテストや検証を行う。
5. 実装内容を報告し、ユーザーの明示的なOKを待つ。
6. OK後にだけquestを更新する。

quest更新時:

- `## 実装メモ`に対象タスクの結果を追記する。
- `## 対応状況`の対象チェックボックスを`[ ]`から`[x]`へ変更する。
- 方針判断、質問、回答、重要な発見は`## やり取り履歴`の末尾に追記する。
- 次のタスクは勝手に開始しない。

## 重要ルール

- questはMarkdownだが、作業の状態管理ファイルとして扱う。
- active/completedの両方を必要に応じて確認する。
- repo横断タスクでは、questを共有掲示板として扱う。
- 1 repo = 1 IDE = 1 agentの原則を尊重する。
- 同一repo内で複数タスクを並列実装しない。
- ユーザーのOKなしでチェックボックスを完了扱いにしない。

