# config.toml 補足説明

Codex CLI のグローバル設定（`~/.codex/config.toml`、実体は本ファイルと同ディレクトリ）。
プロジェクト直下の `.codex/config.toml` で上書き可能（trusted なプロジェクトのみ読み込まれる）。

> ⚠️ `config.toml` 本体は **gitignore 対象**（`trust_level` にマシン固有の絶対パスや
> NUXフラグ等が入り、Codexが自動書き換えするため）。よって設定変更は**このマシンのローカル**に留まる。
> 本 `.md` は説明用でgit管理される。

## Claude (settings.json) との対応

| Claude `settings.json` | Codex `config.toml` |
|---|---|
| `permissions.defaultMode: "auto"` | `approval_policy` |
| `permissions.allow` / `deny` | `sandbox_mode`（＋ sandbox のガードレール） |
| プロジェクト単位の信頼 | `[projects."<path>"] trust_level = "trusted"` |

Claude は「`Bash(*)` を許可しつつ危険コマンドを `deny` で個別ブロック」する方式。
Codex には**コマンド単位の denylist は無く**、代わりに **sandbox** が守る
（作業ディレクトリ外への書き込み・ネットワークを制御）。ここが思想の違い。

## 承認まわり（都度確認をなくす設定）

```toml
approval_policy = "never"        # 一切確認しない（Claudeのauto相当）
sandbox_mode = "workspace-write" # 作業ディレクトリ内の書き込みは自動許可

[sandbox_workspace_write]
network_access = true            # git push / gh / curl 等を許可
```

### approval_policy の値

| 値 | 挙動 |
|---|---|
| `"untrusted"` | 慎重。多くの操作で確認（デフォルト寄り） |
| `"on-request"` | 普段は聞かず、エージェントが権限昇格を求めた時だけ確認（バランス型） |
| `"never"` | 一切確認しない。非対話・自動運用向け（**現在の設定**） |
| `{ granular = { ... } }` | 項目ごと（sandbox承認・rules・MCP・skill等）に細かく制御 |

### sandbox_mode の値

| 値 | 挙動 |
|---|---|
| `"read-only"` | 読み取りのみ |
| `"workspace-write"` | 作業ディレクトリ内は書き込み可（**現在の設定**）。外部書き込み・ネットワークは既定で遮断 |
| `"danger-full-access"` | sandbox無効。フルアクセス（非推奨） |

`sandbox_workspace_write.network_access = true` で、workspace-write のままネットワークを解禁。
git push を多用するため有効化している。

> セキュリティを上げたい場合は `approval_policy = "on-request"` に戻すと、
> 危険操作の直前だけ確認が入る（利便性と安全性のバランス）。

## その他のキー

| キー | 値 | 備考 |
|-----|-----|------|
| `model` | `"gpt-5.5"` | 使用モデル |
| `model_reasoning_effort` | `"xhigh"` | 推論の深さ |
| `[projects."<path>"] trust_level` | `"trusted"` | そのプロジェクトを信頼し `.codex/` レイヤ（config/hooks/rules）を読み込む |
| `[tui.model_availability_nux]` | 自動生成 | TUIの初回案内フラグ（Codexが管理） |
