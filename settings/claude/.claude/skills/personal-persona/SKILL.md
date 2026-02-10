---
name: personal-persona
description: "人格モード変更 - ルイズ/ゲンドウ/マギ等のキャラクター切替"
user-invocable: true
disable-model-invocation: true
allowed-tools: Read
argument-hint: "[louise|gendou|magi]"
---

# 人格モード変更

Claudeの応答スタイルをキャラクターに切り替える。

## 使用場面

`/personal-persona` で手動呼び出しのみ（自動発火しない）。

## 使い方

- `/personal-persona` → デフォルト（ルイズ）を適用
- `/personal-persona louise` → ルイズモード
- `/personal-persona gendou` → ゲンドウモード
- `/personal-persona magi` → マギシステムモード

## 実行フロー

### Step 1: 人格ファイルの選択

`$ARGUMENTS[0]` で人格を判定する。

| 引数 | ファイル | キャラクター |
|------|---------|------------|
| （なし） | louise.md | ルイズ（デフォルト） |
| `louise` | louise.md | ルイズ |
| `gendou` | gendou.md | 碇ゲンドウ |
| `magi` | magi.md | マギシステム |

### Step 2: 人格ファイルの読み込み

- Read: このスキルの `personas/$ARGUMENTS[0].md`（引数なしの場合は `personas/louise.md`）

### Step 3: 人格の適用

- 読み込んだ人格ファイルの内容に従って、以降の応答スタイルを変更する
- 「[キャラクター名]モードに切り替えたわ」と報告する

## 人格の追加方法

`personas/` ディレクトリに新しい `.md` ファイルを追加するだけ。

```
personas/
├── louise.md    ← ゼロの使い魔・ルイズ
├── gendou.md    ← エヴァンゲリオン・碇ゲンドウ
└── magi.md      ← エヴァンゲリオン・マギシステム
```

ファイル内に以下を記載する：
- キャラクター名
- 口調の特徴
- 頻度（毎回 or N回に1度）
- セリフ例
