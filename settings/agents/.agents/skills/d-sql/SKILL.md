---
name: d-sql
description: "SQL実行 - Sequel Aceの接続情報を流用してMySQLにクエリを発行する。「DBで〜」「○○のテーブル見て」「SQL叩いて」と言われた時に使用する。"
user-invocable: true
disable-model-invocation: false
allowed-tools: Bash, AskUserQuestion
argument-hint: "[接続名] [SQL]"
---

# SQL実行（Sequel Ace連携）

ローカルの `db-query` コマンドを介して、Sequel Aceに登録済みの接続でMySQLクエリを実行する。

## 使用場面

Claudeは以下の状況で**自動的にこのスキルを適用**する：

- 「`<DB名>`でSELECTして」「`<DB名>`のテーブル見せて」と言われた時
- 「SQL叩いて」「DBに問い合わせて」と言われた時
- データ確認・テストデータ投入・スキーマ確認などDB操作全般

また、`/d-sql` で手動呼び出しも可能。

## 接続種別ポリシー（重要）

`db-query` は接続名で権限を分けている。skill側もこのポリシーに従うこと：

| 種別 | 判定 | 権限 |
|------|------|------|
| **local系** | `dev(` `stage(` 以外 | 全SQL可（破壊的SQLは確認） |
| **dev系** | name先頭が `dev(` | **read-only**（SELECT/SHOW/DESCRIBE/EXPLAIN/USE/SET/HELP/WITH のみ） |
| **stage系** | name先頭が `stage(` | **read-only** |

dev/stageは `db-query` 側でも強制ブロックされる。**回避策はない**（恒久的な保護）。

## 実行フロー

### Step 1: 接続名の決定

- **引数に接続名がある** → そのまま使う
- **無い・曖昧** → `db-query --list` で一覧取得 → AskUserQuestion でユーザーに選ばせる
- 部分一致もOK（`db-query` 側で一意なら通る、複数該当ならエラー）

### Step 2: SQLの構築

- ユーザー要望を解釈してSQLを組み立てる
- `LIMIT` 未指定のSELECTには **`LIMIT 100` を付ける**（誤爆防止）
- カラム名・テーブル名は事前に `SHOW TABLES` / `DESCRIBE` で確認してから本クエリを組むのが望ましい

### Step 3: 破壊的SQLの確認（local系のみ）

以下のいずれかに該当する場合は**実行前に必ず AskUserQuestion で確認**する：

- `DROP TABLE` / `DROP DATABASE` / `DROP INDEX`
- `TRUNCATE`
- `DELETE` で `WHERE` 句なし
- `UPDATE` で `WHERE` 句なし
- `ALTER TABLE` で `DROP COLUMN` を含む

確認文例：

```
AskUserQuestion:
  question: "破壊的SQLです。実行していいですか？\n\n接続: cel(local)\nSQL: TRUNCATE users"
  header: "確認"
  options:
    - label: "実行する"
      description: "このSQLを実行する"
    - label: "中止"
      description: "実行しない"
```

### Step 4: 実行

```bash
db-query -c "<接続名>" -e "<SQL>"
```

- **複数行・長いSQL** は heredoc やファイル経由で stdin から流す：
  ```bash
  db-query -c "cel(local)" <<'SQL'
  SELECT u.id, u.name
  FROM users u
  WHERE u.deleted_at IS NULL
  LIMIT 10;
  SQL
  ```

### Step 5: 結果整形

- mysql コマンドの素の出力をそのまま貼らない。**Claudeが要約 or 整形**して返す
- 件数が多い場合は「N件中先頭10件を表示」のように上限を示す
- スキーマ確認結果（`DESCRIBE`）は**カラム名と型だけ**を抜粋

## エラーハンドリング

| エラー | 対処 |
|--------|------|
| `Password not found in Keychain` | Sequel Aceで該当接続を一度開いてパスワード保存を促す |
| `No connection matching '...'` | `db-query --list` で候補を提示しAskUserQuestion |
| `Multiple connections match '...'` | 候補一覧をユーザーに見せて選び直してもらう |
| `READ-ONLY` 拒否 | dev/stageでは書き込み不可と伝え、ローカルDBへの切替を提案 |
| MySQL構文エラー | エラーメッセージをそのまま見せて、修正案を提示 |

## 重要ルール

- **db-queryの`--force`等のreadonly解除フラグは存在しない**。dev/stageへの書き込みは諦めること
- 接続情報・パスワードを **Bashコマンドのログや結果整形に絶対に含めない**
- SELECTで件数を絞らないクエリは禁止（`LIMIT` 必須、または `COUNT` で件数確認してから）
- ユーザーが明示的に許可しない限り、**スキーマ変更（DDL）は提案しない**