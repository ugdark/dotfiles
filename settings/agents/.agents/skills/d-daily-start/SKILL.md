---
name: d-daily-start
description: "daily日報の自動準備 - 前日daily の「やる事」を今日の「やった事」に転記し、Googleカレンダーから今日と翌出勤日の予定を取得して挿入する。「日報書く」「日報始める」「dailyスタート」と言われた時に使用する。"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, mcp__claude_ai_Google_Calendar__list_events
argument-hint: ""
---

# daily日報の自動準備

`~/.dotfiles/vault/daily/GGGG-WWW/YYYY-MM-DD.md` を準備し、前日予定の転記と Google カレンダーからの予定挿入をまとめて行う。
（daily は週フォルダ `GGGG-WWW`（例 `2026-W27`。ISO週年+ISO週）配下に置く。`date +%G-W%V` で得る。Obsidian側フォーマット `GGGG-[W]WW` と一致させる）

## 使用場面

Claudeは以下の状況で**自動的にこのスキルを適用**する：

- 「日報書く」「日報始める」「dailyスタート」「daily用意して」と言われた時

また、`/d-daily-start` で手動呼び出しも可能。

## 前提

- daily テンプレート: `~/.dotfiles/vault/templates/daily.md`
- daily 保存先: `~/.dotfiles/vault/daily/GGGG-WWW/YYYY-MM-DD.md`（週フォルダ配下。例 `2026-W27`）
- カレンダー取得は MCP `claude_ai_Google_Calendar`（事前に `/mcp` で認証済みであること）

## 実行フロー

### Step 1: 今日の日付決定

- Bash: `date +"%Y-%m-%d"` で今日の日付を取得
- Bash: `LANG=ja_JP.UTF-8 date +"%a"` で曜日を取得（月火水木金土日）
- Bash: `date +"%G-W%V"` で週フォルダ名を取得（例 `2026-W27`。ISO週年+ISO週。年末年始も正しく処理）
- 今日のファイルパス: `~/.dotfiles/vault/daily/<週フォルダ>/YYYY-MM-DD.md`

### Step 2: 今日の daily ファイル準備

- 既に存在する場合: そのまま使う（**既存内容は破壊しない**）
- 存在しない場合: テンプレを読み、`{{date:YYYY-MM-DD (ddd)}}` を `YYYY-MM-DD (曜)` に置換して Write
  - 週フォルダが無ければ Write 前に `mkdir -p ~/.dotfiles/vault/daily/<週フォルダ>` で作成する

### Step 3: 前日 daily の特定と「やる事」転記

- Bash: 週フォルダ配下を横断し、**ファイル名（日付）順**で今日の1つ前を取る:
  `find ~/.dotfiles/vault/daily -name '????-??-??.md' | awk -F/ '{print $NF"\t"$0}' | sort | cut -f2- | grep -B 1 "/YYYY-MM-DD.md$" | head -1`
  - フルパスではなく basename（日付）でソートするため、週フォルダをまたいでも正しく前日が取れる
  - 該当なしの場合は Step 3 をスキップして Step 3b へ
- 前日ファイルを Read し、**`## やる事` セクションの本文**を抽出
- 今日のファイルの `## やった事` セクション直下に、抽出した内容を Edit で挿入
  - 既に「やった事」に手入力がある場合は**追記**（先頭挿入。手入力を上書きしない）

### Step 3b: 今日の quest を Obsidianリンクで転記

ファイル名だけ把握できればよい（中身は quest ファイル自体を見ればわかるため、本文抽出はしない）。2系統で対象 quest を集める：

**(A) 今日新規作成された active quest**（ファイル名で判定）
- Bash: `ls ~/.dotfiles/vault/quests/active/$(date +%Y%m%d)_*_quest.md 2>/dev/null`

**(B) 今日完了させた quest**（更新日で判定）
- Bash: `find ~/.dotfiles/vault/quests/completed -name '*.md' -newermt "$(date +%Y-%m-%d) 00:00" 2>/dev/null`

**追記**
- 各ファイルのbasename（拡張子除去）に対し、Obsidian wiki-link を alias 付きで生成し `## やった事` セクション**先頭**に追記
  - (A) active: `- [[20260513_01_daily日報自動化_quest|quest: daily日報自動化]]`
  - (B) completed: `- [[20260501_01_ETL_OnDB切替_quest|quest: ETL_OnDB切替 (completed)]]`
  - 機能名はファイル名から `yyyyMMdd_NN_` プレフィックスと `_quest` サフィックスを除去して抽出
- **重複追記しない**: 既に「やった事」セクションに同じファイル名のwiki-link（`[[<basename>_quest|...]]`）が存在する場合はスキップ。再実行時の二重追記を防ぐ
- Step 3 で挿入した前日「やる事」転記より上に配置する
- (A)(B)合わせて0件ならスキップ

### Step 4: 今日の予定取得（MCP）

- `mcp__claude_ai_Google_Calendar__list_events`:
  - `startTime`: `YYYY-MM-DDT00:00:00+09:00`
  - `endTime`: `YYYY-MM-DDT23:59:59+09:00`
  - `timeZone`: `Asia/Tokyo`
  - `orderBy`: `startTime`
- 取得した events を `HH:mm 〜 HH:mm summary` 形式の箇条書きに整形
  - 終日イベントは `[終日] summary`
- 今日のファイルの `## 本日の予定` セクションの本文を**書き換える**（マーカーコメント行は削除する）

### Step 5: 翌出勤日の算出

- 候補 = 今日 + 1日
- ループ:
  1. `候補の曜日 in (土, 日)` なら 候補 += 1日 → continue
  2. `mcp__claude_ai_Google_Calendar__list_events` で `ja.japanese#holiday@group.v.calendar.google.com` を `候補日の0時〜24時` で取得
  3. レスポンスの events のうち **`description == "祝日"`** のものが1件以上あれば 候補 += 1日 → continue
     - **重要**: `description == "祭日"`（雛祭り・七夕等の年中行事）は休日扱いしない
  4. 上記いずれも満たさなければ「翌出勤日」確定

### Step 6: 翌出勤日の予定取得・挿入

- Step 4 と同様に `list_events` で翌出勤日の予定を取得
- 今日のファイルの `## 次の日の予定` 見出しを `## 次の日の予定 (YYYY-MM-DD 曜)` に書き換え、本文を予定一覧に置き換える

### Step 6b: 未完了の active quest を末尾追記

- Bash: `~/.dotfiles/vault/quests/active/*_quest.md` を列挙
- 各ファイルに対し `- [ ]` の行があれば「未完了タスクが残る」と判定（全タスク完了 = `[x]` のみの quest は除外）
- 対象を `## アクティブなquest` セクションの本文に書き換え（マーカーコメントは削除）
  - 形式: `- [[20260513_01_daily日報自動化_quest|daily日報自動化]]`（機能名のみ。`quest:` プレフィックスは付けない）
- 0件なら本文を空にする（セクション見出しは残す）

### Step 7: 完了報告

- 報告内容:
  - 用意した daily ファイルパス
  - 前日からの転記: 何件あったか（0件ならスキップした旨）
  - 今日完了したquestタスク: N件追記（0件ならスキップした旨）
  - 今日の予定: N件挿入
  - 翌出勤日: YYYY-MM-DD（曜）/ N件挿入
  - 未完了 active quest: N件追記
  - 祝日スキップが発生した場合は「YYYY-MM-DD は祝日（祝日名）のためスキップ」も併記

## エラーハンドリング

| エラー | 対処 |
|--------|------|
| MCP 未認証 | 「`/mcp` で claude.ai Google Calendar を認証してください」と案内して中止 |
| テンプレート未存在 | `~/.dotfiles/vault/templates/daily.md` がない旨を伝えて中止 |
| 前日 daily が見つからない | Step 3 をスキップし、その旨を完了報告に含める |

## 重要ルール

- **既存セクション本文は破壊しない**。書き換え対象は「本日の予定」「次の日の予定」「やった事」の自動挿入領域のみ
- **マーカーコメント行（`<!-- ... -->`）は挿入完了後に削除する**（生成された daily に Claude 用のメタコメントを残さない）
- 祝日判定は `description == "祝日"` のみ（`"祭日"` は平日扱い）
- 既に今日の daily が完成済み（手入力で全項目埋まってる）でも本日の予定・次の日の予定は**最新カレンダー情報で上書き**する（最新化目的）
- やった事への前日予定転記は**重複追記しない**（既に同内容があればスキップ）