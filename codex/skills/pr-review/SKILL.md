---
name: pr-review
description: 現在のワークスペースにチェックアウトされているブランチに対応するgithubのプルリクエストに対して、コードレビューを行います。 個別の観点を担当するサブエージェントがこのスキルを読むことは禁止します。
---

## このスキルを用いて行うこと

貴方は、プルリクエストの受入れ担当者として、サブエージェントを用いてgithub のプルリクエストをレビューし、プルリクエストが受入れ可能であるかどうかを判定し、必要であれば修正すべき点を網羅的に指摘してください。
レビュー結果は`review_${プルリクエストID}_${ブランチ名}.md`ファイルに、markdown 形式で出力してください。

- ワークスペースにはすでにレビュー対象のプルリクエストのブランチがチェックアウトされています
- `scripts/`配下の収集コマンドを使って、プルリクエストの ID、プルリクエストの情報、diff、変更ファイル一覧、関連 issue 情報を取得し、レビューに利用してください
  - `fetch_repo_info.sh`で、現在のワークスペースに対応するリポジトリ情報とプルリクエスト ID を取得してください
  - `fetch_pr_info.sh` `fetch_pr_diff.sh` `fetch_changed_files.sh` `fetch_related_issues.sh` で、レビューに必要な情報を個別ファイルとして保存してください
  - github 関連のツールは、収集済みファイルだけでは足りない調査が必要になった場合の補助手段として利用してください
- プルリクエストの diff を取得するときに`origin/develop`(デフォルトブランチ)との diff を取得しないでください
  - 現在のブランチが up to date な状態であるとは限りません
  - up to date な状態で無い場合、デフォルトブランチとのdiffは適切なdiffになりません。
  - 必ず`fetch_pr_diff.sh`を利用して、プルリクエストそのものの diff を取得してください
- 実際のレビュー作業はサブエージェントに担当させ、あなたはサブエージェントの管理と、最終的なレビュー結果のまとめを担当してください


## 重要な注意事項

- `レビューの手順` は `plan tool`（TODOs）を用いて実施してください。
    - この手順は非常に長く、あなたが手順の詳細を忘れてしまう可能性があります。
    - 忘れてしまうのを防ぐため、各項目は、要約せず、サブアイテムを含めて全文をTODOに入れてください。


## レビューの手順

1. プルリクエストの ID を特定し、プルリクエストの情報を取得してください
    - `scripts/fetch_repo_info.sh`を実行し、`.agent/temp/pr_review/repo_info.json`に保存してください
    - `.agent/temp/pr_review/repo_info.json`から`owner` `repo` `pullRequestNumber`を読み取ってください
2. プルリクエストの diff や 関連課題の情報など、レビューに必要な情報を取得してください
    - `scripts/fetch_pr_info.sh`で`.agent/temp/pr_review/pr_info.json`を作成してください
    - `scripts/fetch_pr_diff.sh`で`.agent/temp/pr_review/pr.diff`を作成してください
    - `scripts/fetch_changed_files.sh`で`.agent/temp/pr_review/changed_files.json`を作成してください
    - `scripts/fetch_related_issues.sh`で、関連 issue の本文と全コメントを含む`.agent/temp/pr_review/related_issues.json`を作成してください
    - 取得した内容は`.agent/temp/pr_review`以下の一時ファイルとして保存してください
3. レビュー観点ごとにサブエージェントを新規に起動してレビューを実施させてください
    - `references/review-points`ディレクトリには、レビュー観点ごとにファイルが分かれて保存されています
    - サブエージェントにやらせること
        - サブエージェントには、`あなたは個別の観点を担当するサブエージェントである`ということを認識させてください
        - レビュー観点ファイルごとに、サブエージェントを作成し、レビューを実施させてください
            - サブエージェントには、担当する観点ファイルへのファイルパス・2で保存した`pr_info.json` `pr.diff` `changed_files.json` `related_issues.json`・その他レビューに必要な情報を与えてください
        - `related_issues.json`は、関連 issue の本文と全コメントを含む一次情報として扱い、要件の背景や議論経緯の確認に利用させてください
        - サブエージェントには、プルリクエストの diff だけでなく、関連するコードを含めて調査し、レビューに役立てるよう指示してください
        - サブエージェントには、なにか問題が見つかってもそこでレビューを止めず、レビュー対象コード全体を通して、問題がないかどうかを確認するように指示してください
    - サブエージェントにやらせないこと
        - レビュー結果のファイルへの出力は、あなたが行ってください。サブエージェントには、レビュー結果をファイルに出力させないでください
        - `.agent/temp/pr_review/`以下のファイルの削除は、あなたが行ってください。サブエージェントには、これらのファイルを削除させないでください
4. サブエージェントの上限で起動できなかったエージェントがあれば、他のエージェントのレビューが完了するのを待ち、その後にレビューを実施させてください
    - 必ず全ての観点でサブエージェントを起動するようにしてください
    - 全ての観点でサブエージェントが起動するまで、4を繰り返してください
5. 全ての観点のレビューが完了するのを待ち、レビュー結果をまとめ、最終的なレビュー結果をファイルに、markdown 形式で出力してください
    - 必ず全ての観点のレビュー結果を統合して、最終的なレビュー結果を作成してください
    - あとから起動したサブエージェントのレビュー結果も、最終的なレビュー結果に統合するようにし、レビュー観点が抜けることがないようにしてください
6. 2で作成したファイルを削除してください
    - `.agent/temp/pr_review`以下に作成した収集コマンドの出力ファイルを削除してください

## レビュー指摘の書式

- 個別の指摘に重要度を表すタグを付与してください。
  - `[P1]`が最も重要度が高い
  - `[P8]`が最も重要度が低い
- レビュー観点ごとに項を分けてください
    - 対象のレビュー観点の名前を見出しにしてください
    - その観点での指摘が無ければ、`指摘なし`と記載してください
- 指摘には以下を必ず加えてください。
  - 指摘の対象ソースファイルと行数
    - 複数の箇所にまたがる場合は、すべての箇所を記載してください
  - 指摘の対象ソースコードの該当部分の抜粋
    - 複数ヶ所に対して同じ指摘を行う場合は、代表的な箇所のみで構いません
    - 抜粋の範囲が20行を超える場合は、指摘を理解するのに必要な最小限の抜粋のみで構いません
  - 指摘の概要
  - 指摘の詳細な説明
  - 修正案
- プレーンテキストとして読んでも、人間の可読性が十分に高くなるよう、適切な改行や箇条書きを用いてください。

## 収集コマンド

### `fetch_repo_info.sh`

現在のワークスペースから、`owner`、`repo`、`nameWithOwner`、`pullRequestNumber`を取得するコマンドです。

実行例:

```bash
scripts/fetch_repo_info.sh .agent/temp/pr_review/repo_info.json
```

### `fetch_pr_info.sh`

対象プルリクエストの本文、base/head ブランチ、変更件数、ラベル、関連 issue 参照などのメタデータを取得するコマンドです。

実行例:

```bash
repo_info_json=.agent/temp/pr_review/repo_info.json
owner=$(jq -r '.owner' "$repo_info_json")
repo=$(jq -r '.repo' "$repo_info_json")
pull_request_number=$(jq -r '.pullRequestNumber' "$repo_info_json")
scripts/fetch_pr_info.sh "$owner" "$repo" "$pull_request_number" .agent/temp/pr_review/pr_info.json
```

### `fetch_pr_diff.sh`

対象プルリクエストそのものの diff を取得するコマンドです。デフォルトブランチとの差分は取得しません。

実行例:

```bash
repo_info_json=.agent/temp/pr_review/repo_info.json
owner=$(jq -r '.owner' "$repo_info_json")
repo=$(jq -r '.repo' "$repo_info_json")
pull_request_number=$(jq -r '.pullRequestNumber' "$repo_info_json")
scripts/fetch_pr_diff.sh "$owner" "$repo" "$pull_request_number" .agent/temp/pr_review/pr.diff
```

### `fetch_changed_files.sh`

対象プルリクエストで変更されたファイル一覧を取得するコマンドです。

実行例:

```bash
repo_info_json=.agent/temp/pr_review/repo_info.json
owner=$(jq -r '.owner' "$repo_info_json")
repo=$(jq -r '.repo' "$repo_info_json")
pull_request_number=$(jq -r '.pullRequestNumber' "$repo_info_json")
scripts/fetch_changed_files.sh "$owner" "$repo" "$pull_request_number" .agent/temp/pr_review/changed_files.json
```

### `fetch_related_issues.sh`

対象プルリクエストの`closingIssuesReferences`を起点に、関連 issue の本文と全コメントを含む詳細を JSON 配列で取得するコマンドです。関連 issue が無ければ空配列を出力します。出力は LLM が読む一次情報であり、人間向けの整形ファイルは作成しません。

実行例:

```bash
repo_info_json=.agent/temp/pr_review/repo_info.json
owner=$(jq -r '.owner' "$repo_info_json")
repo=$(jq -r '.repo' "$repo_info_json")
pull_request_number=$(jq -r '.pullRequestNumber' "$repo_info_json")
scripts/fetch_related_issues.sh "$owner" "$repo" "$pull_request_number" .agent/temp/pr_review/related_issues.json
```
