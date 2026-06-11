# settings.json 補足説明

Claude Code グローバル設定（全プロジェクト共通）。
プロジェクトの `.claude/settings.json` や `settings.local.json` で上書き可能。

## permissions

`allow`: 確認なしで実行を許可、`deny`: 実行を拒否。

### allow

| エントリ | 理由 |
|---------|------|
| `WebSearch`, `WebFetch`, `Read`, `Glob`, `Grep` | 検索・読み取り系は副作用なしのため全プロジェクト許可 |
| `Bash(*)` | 全コマンド許可（危険操作は deny でブロック） |
| `Skill` | スキル実行を確認なしで許可 |
| `Edit/Write(~/Works/**)` | ~/Works/ への書き込みを許可 |
| `Edit/Write(~/.dotfiles/**)` | ~/.dotfiles/ への書き込みを許可 |
| `mcp__github__*` | GitHub MCPツール（tokenの権限範囲内で動作） |
| `mcp__ide__*` | IntelliJ IDE統合（Update権限は未解決。公式ドキュメント未整備） |

### deny

| エントリ | 理由 |
|---------|------|
| `Bash(rm -rf *)`, `Bash(sudo *)` | ファイル/ディレクトリの破壊的削除 |
| `Bash(git push --force *)` 等 | git履歴改変・データ消失系 |
| `Bash(gh repo delete *)` 等 | GitHub上の破壊的操作 |

### defaultMode

`"auto"` に設定。`skipAutoPermissionPrompt: true` と合わせて、セッション起動時から確認なしで動作する。

## その他

| キー | 値 | 備考 |
|-----|-----|------|
| `model` | `"sonnet"` | デフォルトモデル |
| `language` | `"japanese"` | 応答言語 |
| `effortLevel` | `"medium"` | 思考の深さ。`high` にすると長考が見られたため medium に |
| `showThinkingSummaries` | `false` | 思考プロセスの要約を表示しない |
| `skipAutoPermissionPrompt` | `true` | autoモード起動時の確認ダイアログをスキップ |
| `statusLine` | コマンド指定 | ターミナル下部にコスト等を常時表示（後述） |

## statusLine

`~/.claude/statusline.sh` を実行してその stdout をステータスラインに表示する。

```json
"statusLine": {
  "type": "command",
  "command": "~/.claude/statusline.sh"
}
```

スクリプト（`settings/claude/.claude/statusline.sh`）は以下を表示：

- モデル名
- コスト（USD→JPY換算、固定レート 160円/ドル）
- 経過時間
- コンテキスト使用率

表示例: `[Claude Sonnet 4.6] 💰 ¥2.4 | ⏱️ 5m 12s | ctx: 23%`
