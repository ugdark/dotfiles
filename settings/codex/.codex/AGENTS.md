# Codex Global Guidance

このファイルは、個人環境でCodexを使う際の全体ガイドです。
ユーザーから別指定がない限り、日本語で応答してください。

## 基本方針

- まず既存の構成・文体・運用を読んでから作業してください。
- 検索には可能な限り`rg`と`rg --files`を使ってください。
- ユーザーの変更を保持してください。無関係なdirty fileを戻さないでください。
- `git reset --hard`、`git clean`、広範囲の`rm`、force pushのような破壊的操作は、ユーザーが明示した場合だけ実行してください。
- ユーザーが明示しない限り、commit、push、stageはしないでください。
- 既存ファイルのスタイルに合わせ、小さく焦点の絞られた編集を優先してください。

## dotdesk / vault

個人作業では、各プロジェクト直下の`.desk`が`~/.dotfiles/vault`へのsymlinkとして使われます。
`.desk`はglobal gitignoreで除外される前提です。

`vault/`はdotfiles本体から見るとignore対象ですが、通常の作業対象です。
ノート、quest、daily、knowledge-base更新を依頼された場合は、`vault/`または`.desk/`配下を編集してかまいません。

主なパス:

- `~/.dotfiles/vault/quests/`: quest管理
- `~/.dotfiles/vault/knowledge-base/`: public knowledge-base
- `~/.dotfiles/vault/articles/zenn/articles/`: Zenn記事の元原稿
- `.desk/quests/`: プロジェクトから見えるquest
- `.desk/knowledge-base/`: プロジェクトから見えるknowledge-base
- `.desk/articles/zenn/articles/`: プロジェクトから見えるZenn記事

## Git管理境界

dotfiles環境には複数のGitリポジトリがあります。

- `~/.dotfiles`: dotfilesリポジトリ
- `~/.dotfiles/vault`: privateなObsidian/vaultリポジトリ
- `~/.dotfiles/vault/knowledge-base`: publicなknowledge-baseリポジトリ

`git status`は、必ず編集対象のリポジトリで個別に確認してください。
dotfilesルートの`git status`だけで`vault/`や`knowledge-base/`の状態を判断しないでください。

## Quest運用

questは、旧`plan`運用を引き継いだMarkdownベースの作業単位です。
設計思想は以下の記事を参照してください。

- `.desk/articles/zenn/articles/dotdesk-plan-cross-repo.md`
- `.desk/articles/zenn/articles/claude-code-personal-skills.md`

重要な考え方:

- questはリポジトリに強く紐づけず、`vault/quests/active/`で横断管理します。
- repo間連携はquestファイルを共有掲示板として扱います。
- 同一repoで複数セッションを同時に進めるのではなく、1 repo = 1 IDE = 1 agentを基本にします。
- 並列は別repoまたは別cloneで行います。
- questのチェックボックスは1つずつ進めます。
- 実装後はユーザー確認を待ち、OK後にquestのチェックと実装メモを更新します。
- 判断・質問・回答は`## やり取り履歴`の末尾に時系列で追記します。

questファイルは主に以下のセクションを持ちます。

- `## 要望・要件`
- `## ブランチ名`
- `## 対応状況`
- `## 概要`
- `## 完了条件`
- `## 調査ログ`（調査系questの場合）
- `## 実装メモ`
- `## やり取り履歴`

questを読み込む時は、`## 対応状況`内のチェックボックスだけを進捗として数えてください。
ファイル全体のチェックボックスを雑に数えないでください。

## Knowledge Base

`vault/knowledge-base/`配下にページを追加・移動する場合:

- 最も適切なカテゴリディレクトリに配置してください。
- 既存カテゴリが合わない場合だけ、新しいカテゴリディレクトリを作成してください。
- カテゴリ一覧に出すべきページを追加した場合は、`README.md`を更新してください。
- docs navigationに出すべきページを追加した場合は、`_sidebar.md`を更新してください。
- `vault/knowledge-base/`は独立したGitリポジトリとして扱ってください。

## 検証

変更内容に対して、必要最小限かつ有効な検証を行ってください。

- shell script変更: 可能なら`bash -n path/to/script.sh`を実行してください。
- Markdownのみの変更: リンク、カテゴリ配置、navigation entriesを確認してください。
- Stow管理設定: 対象pathを確認し、依頼がない限りlocal-only fileは変更しないでください。
- Git状態の要約: 影響した各リポジトリで個別に確認してください。

検証できなかった場合は、何をなぜ検証できなかったのかを明示してください。

