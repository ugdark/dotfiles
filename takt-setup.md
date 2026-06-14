# takt セットアップ手順

TAKT（AI Agent Workflow Orchestration）の導入手順。

## 前提

- Node.js >= 18.19.0
- Claude Code CLI（認証済み）
- tmux（claude-terminal プロバイダーを使う場合）

## インストール

```bash
# tmux（claude-terminal に必要）
brew install tmux

# takt 本体
npm install -g takt
```

## 設定

```bash
mkdir -p ~/.takt
```

`~/.takt/config.yaml` を作成：

```yaml
provider: claude-headless   # Claude Code CLIをheadlessモードで使用（APIキー不要・サブスク認証を流用）
language: ja
```

### プロバイダーの違い

| provider | 認証 | tmux | 備考 |
|---------|------|------|------|
| `claude-headless` | Claude Code CLIの既存認証 | 不要 | **推奨**。`claude -p` で起動する安定版 |
| `claude-terminal` | Claude Code CLIの既存認証 | 必要 | experimental。tmux経由でCLI操作 |
| `claude` | `TAKT_ANTHROPIC_API_KEY`（APIキー） | 不要 | 速いが別途APIキー管理が必要 |

## 基本的な使い方

```bash
# AIと相談してタスクを積む
takt

# 積んだタスクを実行（計画→実装→レビュー→修正）
takt run

# タスク一覧・管理
takt list

# GitHub Issue をタスク化
takt add #6
takt run
```

## セキュリティ

- テレメトリ（外部送信）はOTLPエンドポイントをenv varで設定しない限り無効
- takt自体はMCPサーバーを追加しない
- `claude-terminal` はClaude Codeの認証チャンネルをそのまま使うため、追加のAPI管理不要

## 参考

- [README（日本語）](https://github.com/nrslib/takt/blob/main/docs/README.ja.md)
- バージョン: 0.45.0（導入時点）
