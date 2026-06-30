# CLAUDE.md

このファイルはClaude Code (claude.ai/code) がこのリポジトリで作業する際のガイドです。

## 概要

macOS向けの個人dotfilesリポジトリ（owner: ugdark）。GNU Stowでシンボリックリンクを管理し、`git clone` + `install.sh` で環境構築が完了する。

リポジトリ構成・セットアップ手順・設計上のポイントは [README.md](./README.md) を参照。

## skills（d-*）の設計方針

`settings/agents/.agents/skills/` 配下のスキル（実体マスター。Claude/Codex がsymlinkで共有）は **汎用的** に作る。

- **プロダクト・言語に依存しない**: 特定のフレームワーク（sbt, npm等）やレイヤー構造（domain/gateway等）をスキル内にハードコードしない
- **プロジェクト固有の設定はCLAUDE.mdに委任**: フォーマッタ、テストコマンド、レイヤー構成等は各プロジェクトのCLAUDE.mdに記載し、スキルはそれを参照する
- **テンプレートはシンプルに**: questテンプレートには構造だけ置き、具体的な内容はreview時に埋める
