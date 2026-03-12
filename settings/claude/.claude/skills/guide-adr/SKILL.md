---
name: guide-adr
description: "ADR作成とメンテナンス - Architecture Decision Recordsの作成・移動・形式チェック。「ADRを作って」「ADRを書いて」「技術決定を記録して」と言われた時に使用する。"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob
---

# ADR作成とメンテナンス

プロジェクトのADR（Architecture Decision Records）を作成・管理するガイドライン。

## ADRの基本

ADRは、プロジェクトで行われた重要な技術的決定を文書化する仕組み。

**目的**:
- なぜその技術的決定を行ったのか、理由を明確にする
- 将来のメンバーが過去の決定を理解できるようにする
- 決定の背景・選択肢・結果を記録し、チームの知見として蓄積する

## ファイル配置

ADRは以下のディレクトリに配置する:

```
docs/adr/
├── YYYYMMDD_NN_xxx.md  # 個別のADR
└── assets/             # 画像などのアセット
    └── YYYYMMDD_NN_*.png # 対応するADRのPrefixをあわせる
```


## ADR作成手順

### 1. ファイル命名規則

```
YYYYMMDD_NN_タイトル.md
```

- `YYYYMMDD`: 決定日（例: 20260205）
- `NN`: 連番（01, 02, ...）
- `タイトル`: 決定内容を簡潔に表現（日本語可）

### 2. テンプレート構造

ADRは以下の構造に従う（TEMPLATE.mdを参照）:

```markdown
# [タイトル]

**ステータス**: [提案中 | 承認済み | 却下 | 廃止]
**日付**: YYYY-MM-DD

---

## コンテキスト（Context）
## 決定（Decision）
## 選択肢（Options）
## 根拠（Rationale）
## 結果（Consequences）
## 参考資料（References）
## メモ
```

### 3. ステータスの定義

- **提案中**: 検討中、まだ決定していない
- **承認済み**: チームで合意が取れた
- **却下**: 検討の結果、採用しないことを決定
- **廃止**: 過去に採用したが、現在は使われていない

## ユーザーリクエストへの対応

### ADR作成依頼の場合

1. 背景・問題点・選択肢・決定内容をヒアリング
2. `.claude/skills/guide-adr/TEMPLATE.md` をコピーして `docs/adr/YYYYMMDD_NN_タイトル.md` として作成
3. 各セクションを埋める
4. 必要に応じて `docs/adr/assets/` に画像を配置

## 重要な注意事項

### ファイル形式の統一

- タイトル: `# [タイトル]` （ADR-XXXX: プレフィックスは不要）
- ステータス: 4種類（提案中/承認済み/却下/廃止）のみ
- 日付: `YYYY-MM-DD` 形式

### TEMPLATE.mdとの整合性

- **常に `TEMPLATE.md` を基準とする**
- エディタやlinterが自動整形する場合があるが、TEMPLATE.mdの形式を維持する
- 他のADRとの形式の違いを発見した場合は、TEMPLATE.mdに合わせて修正する


## 良いADRのポイント

- 複数の選択肢を比較検討し、なぜその決定に至ったかを明記する
- 却下した場合も理由を残す（将来の再検討時に役立つ）
- 図やBefore/Afterがあると説得力が増す（`assets/`に配置）

## ADR作成後

ADRの作成・更新が完了したら、`/guide-docs` を呼び出して docs/ 配下のサイドバーやインデックスへの反映を行う。
