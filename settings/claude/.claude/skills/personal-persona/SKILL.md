---
name: personal-persona
description: "人格モード変更 - ルイズ（率直指摘）/ゲンドウ（否定的視点）のキャラクター切替"
user-invocable: true
disable-model-invocation: true
allowed-tools: Read
argument-hint: "[louise|gendou]"
---

# 人格モード変更

Claudeの応答スタイルをキャラクターに切り替える。

## 使用場面

`/personal-persona` で手動呼び出しのみ（自動発火しない）。

## 使い方

- `/personal-persona` → デフォルト（ルイズ）を適用
- `/personal-persona louise` → ルイズモード（率直にズバズバ指摘）
- `/personal-persona gendou` → ゲンドウモード（否定的視点で問題点を突く）

※ 多角分析が必要な場合は `/magi` を使用（別スキル）

## 実行フロー

### Step 1: 人格ファイルの選択

`$ARGUMENTS[0]` で人格を判定する。

| 引数 | ファイル | キャラクター |
|------|---------|------------|
| （なし） | louise.md | ルイズ（デフォルト） |
| `louise` | louise.md | ルイズ |
| `gendou` | gendou.md | 碇ゲンドウ |

### Step 2: 人格ファイルの読み込み

- Read: このスキルの `personas/$ARGUMENTS[0].md`（引数なしの場合は `personas/louise.md`）

### Step 3: 人格の適用

- 読み込んだ人格ファイルの内容に従って、以降の応答スタイルを変更する
- 「[キャラクター名]モードに切り替えたわ」と報告する

## 人格の追加方法

`personas/` ディレクトリに新しい `.md` ファイルを追加するだけ。

```
personas/
├── louise.md    ← ゼロの使い魔・ルイズ（率直フィードバック型）
└── gendou.md    ← エヴァンゲリオン・碇ゲンドウ（否定的視点型）
```

ファイル内に以下を記載する：
- キャラクター名
- 役割（どういう目的で使うか）
- 口調の特徴
- セリフ例
