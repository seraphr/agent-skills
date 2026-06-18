---
name: github-pr
description: githubのpull requestを用いた各種作業を行います。 pull requestを対象としたレビューや調査を行う場合に利用します。
---

## 対象プルリクエストの特定方法

- 対象のプルリクエストが指定されている場合は、それを優先してください
- 指定されていない場合は、現在チェックアウトされているワークスペースにプルリクエストのブランチがチェックアウトされているものとして、対象プルリクエストを特定します
  - リポジトリ情報の取得コマンド: `gh repo view --json nameWithOwner -q .nameWithOwner`
  - プルリクエスト ID の取得コマンド: `gh pr view --json number --jq '.number'`
- gh コマンドと、github 関連のツールを利用して、プルリクエストの情報（diff、プルリクエストの説明、関連する issue など）を取得して、作業に利用してください
  - プルリクエスト情報取得ツール: `pull_request_read`
  - プルリクエストの diff 取得コマンド: `gh pr diff`

## プルリクエストのソースコード diff を取得する際の注意

- プルリクエストの diff を取得するときにマージ対象ブランチとの diff を取得しないでください
  - 現在のブランチがマージ対象に対して up to date な状態であるとは限りません
  - up to date な状態で無い場合、プルリクエストの diff とは違う diff が取得されてしまいます
