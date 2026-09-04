---
name: pr-review
description: 現在のワークスペースにチェックアウトされているブランチに対応するgithubのプルリクエストに対して、コードレビューを行います。 個別の観点を担当するサブエージェントがこのスキルを読むことは禁止します。 またユーザから直接利用することを指定されない限り、このスキルを読むことは禁止します。
---

## このスキルを用いて行うこと

貴方は、プルリクエストの受入れ担当者として、サブエージェントを用いてgithub のプルリクエストをレビューし、プルリクエストが受入れ可能であるかどうかを判定し、必要であれば修正すべき点を網羅的に指摘してください。
あなたはサブエージェントの管理と、最終的なレビュー結果のまとめを担当してください。
レビュー結果は`review_${プルリクエストID}_${ブランチ名}.md`ファイルに、markdown 形式で出力してください。

## 重要な注意事項

- `レビューの手順` は `plan tool`（TODOs）を用いて実施してください。
    - この手順は非常に長く、あなたが手順の詳細を忘れてしまう可能性があります。
    - 忘れてしまうのを防ぐため、各項目は、要約せず、サブアイテムを含めて全文をTODOに入れてください。

## 作業ディレクトリ

サブエージェントからの報告や個別の調査結果、調査中のメモなどを保存するディレクトリとして`.agent/temp/review/leader`を利用してください。
このディレクトリは、あなたが読み書きして利用するための領域です。 最終的な報告には含まれないため好きなように、長い作業で、サブエージェントからの報告や検証結果を忘れてしまわないよう、外部記録領域として利用してください。

## レビューの手順

0. `.agent/temp/review`が存在する場合は動作を停止し、ユーザに一時ディレクトリの削除を促してください。
    - すでに別のレビューが実施中か、以前のレビューの一時ディレクトリが残っている可能性があります。
1. `mkdir -p .agent/temp/review/leader`を実行し、一時ディレクトリを作成してください。
2. プルリクエストの ID を特定し、プルリクエストの情報を取得してください
    - `scripts/fetch_repo_info.sh`を実行し、`.agent/temp/review/repo_info.json`に保存してください
    - `.agent/temp/review/repo_info.json`から`owner` `repo` `pullRequestNumber`を読み取ってください
3. プルリクエストの diff や 関連課題の情報など、レビューに必要な情報を取得してください
    - `scripts/fetch_pr_info.sh`で`.agent/temp/review/pr_info.json`を作成してください
    - `scripts/fetch_pr_diff.sh`で`.agent/temp/review/pr.diff`を作成してください
    - `scripts/fetch_changed_files.sh`で`.agent/temp/review/changed_files.json`を作成してください
    - `scripts/fetch_related_issues.sh`で、関連 issue の本文と全コメントを含む`.agent/temp/review/related_issues.json`を作成してください
    - 取得した内容は`.agent/temp/review/`以下の一時ファイルとして保存してください
4. `<skill root>/references/procedure-manual.md`の内容に従い、サブエージェントによるレビューと結果の統合を行ってください。
    - `<skill root>/references/review-points`ディレクトリには、レビュー観点ごとにファイルが分かれて保存されています
5. 最終的なレビュー結果を markdown 形式で出力してください
6. `rm -rf .agent/temp/review`を実行し、一時ディレクトリを削除してください
    - 削除の際、`.agent/temp/`や`.agent/`は削除しないでください

## 収集コマンド

### `fetch_repo_info.sh`

現在のワークスペースから、`owner`、`repo`、`nameWithOwner`、`pullRequestNumber`を取得するコマンドです。

実行例:

```bash
scripts/fetch_repo_info.sh .agent/temp/review/repo_info.json
```
#### `repo_info.json` の構造

`fetch_repo_info.sh` が出力する `.agent/temp/review/repo_info.json` は、GitHub API のレスポンスをそのまま保存したものではありません。
以下のトップレベルキーを持つフラットな JSON です。

```json
{
  "owner": "kurusugawa-computer",
  "repo": "sensoriz-packages",
  "nameWithOwner": "kurusugawa-computer/sensoriz-packages",
  "pullRequestNumber": 182
}
```


### `fetch_pr_info.sh`

対象プルリクエストの本文、base/head ブランチ、変更件数、ラベル、関連 issue 参照などのメタデータを取得するコマンドです。

実行例:

```bash
repo_info_json=.agent/temp/review/repo_info.json
owner=$(jq -r '.owner' "$repo_info_json")
repo=$(jq -r '.repo' "$repo_info_json")
pull_request_number=$(jq -r '.pullRequestNumber' "$repo_info_json")
scripts/fetch_pr_info.sh "$owner" "$repo" "$pull_request_number" .agent/temp/review/pr_info.json
```

### `fetch_pr_diff.sh`

対象プルリクエストそのものの diff を取得するコマンドです。デフォルトブランチとの差分は取得しません。

実行例:

```bash
repo_info_json=.agent/temp/review/repo_info.json
owner=$(jq -r '.owner' "$repo_info_json")
repo=$(jq -r '.repo' "$repo_info_json")
pull_request_number=$(jq -r '.pullRequestNumber' "$repo_info_json")
scripts/fetch_pr_diff.sh "$owner" "$repo" "$pull_request_number" .agent/temp/review/pr.diff
```

### `fetch_changed_files.sh`

対象プルリクエストで変更されたファイル一覧を取得するコマンドです。

実行例:

```bash
repo_info_json=.agent/temp/review/repo_info.json
owner=$(jq -r '.owner' "$repo_info_json")
repo=$(jq -r '.repo' "$repo_info_json")
pull_request_number=$(jq -r '.pullRequestNumber' "$repo_info_json")
scripts/fetch_changed_files.sh "$owner" "$repo" "$pull_request_number" .agent/temp/review/changed_files.json
```

### `fetch_related_issues.sh`

対象プルリクエストの`closingIssuesReferences`を起点に、関連 issue の本文と全コメントを含む詳細を JSON 配列で取得するコマンドです。関連 issue が無ければ空配列を出力します。出力は LLM が読む一次情報であり、人間向けの整形ファイルは作成しません。

実行例:

```bash
repo_info_json=.agent/temp/review/repo_info.json
owner=$(jq -r '.owner' "$repo_info_json")
repo=$(jq -r '.repo' "$repo_info_json")
pull_request_number=$(jq -r '.pullRequestNumber' "$repo_info_json")
scripts/fetch_related_issues.sh "$owner" "$repo" "$pull_request_number" .agent/temp/review/related_issues.json
```
