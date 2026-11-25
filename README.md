# agent-skills
privateなリポジトリから、共有可能なskillsをコピーしてきたリポジトリ

## 注意

ここにあるskillsは、Codex CLIを対象に調整されています。
他のコーディングエージェントでは意図通り動かないかもしれません。
調整した時期はものによって異なりますが、GPT-5.2〜5.4あたりです。

一部のスキルは、resources ディレクトリにあるファイルをシンボリックリンクで参照しています。
実際に利用する場合は`cp -L`などで、シンボリックリンクを解決してコピーしてください。

----

## エージェント

Codex用エージェント定義のみが置いてあります。

### レビュー用

#### [codex/agents/focused-reviewer.toml](codex/agents/focused-reviewer.toml)

レビュー系スキルから起動される想定の、観点ごとのレビューエージェントです。
弱いモデルを利用し、指摘の候補を列挙することを目的としています。

と言いつつ、gpt-6世代のころに計測した結果、luna だと時間が伸びて微妙だったので、最近は強めのモデルを使っています。

#### [codex/agents/lead-reviewer.toml](codex/agents/lead-reviewer.toml)

レビュー系スキルで利用する想定の、レビュー統括エージェントです。
強いモデルを利用し、`focused-reviewer`が出してきた指摘候補を検証し、最終的なレビュー結果に残すべきものをフィルタすることを目的としています。

### 実装用

#### [codex/agents/luna-developer.toml](codex/agents/luna-developer.toml)

弱いモデル（gpt-6-luna-xhigh）を利用し、個別具体的なコーディングを行うためのエージェントです。
`implement-prepared-issue`スキルから利用されることを想定して定義してあります。

----

## スキル

### コードレビュー

これらのスキルは複数のサブエージェントを起動します。
デフォルトのサブエージェント設定だと、起動可能なエージェント数が足らず、非常に長い時間がかかる場合があります。

```toml
[agents]
max_concurrent_threads_per_session = 12
```

**ワークフロー**

私が行っている、これらのスキルを利用した主なワークフローは以下の通りです。

- レビューをする場合
    - `$run-pr-review`を実施
    - すべての指摘ごとに以下を行う
        1. `$desribe-review <指摘>`で、指摘を理解する
        2. 追加で質問したりして、コメントを作るかどうか、作るとしたらどのようなコメントにするかを決める
        3. `～という方針で、指摘をPRコメントにしてください`のようなプロンプトでPRコメントを作成
    - pending 状態のPRコメントを送信
    - レビューへの対応が行われたら `$check-review-response <review url>`で対応結果を確認
- レビュー結果に対応する場合（自己レビュー）
    - `$run-pr-review`を実施
    - すべての指摘ごとに以下を行う
        1. `$desribe-review <指摘>`で、指摘を理解する
        2. 追加で質問したりして、修正するべきかどうか、修正するとしたらどのような方針にするかを決める
        3. plan モードを用いて計画を作成して実行
        4. コミットを作成
            - https://github.com/openai/symphony/blob/main/.codex/skills/commit/SKILL.md を少し調整したものを使っているが、本リポジトリには入れていない
- レビュー結果に対応する場合（他者レビュー）
    - すべての指摘ごとに以下を行う
        1. `$desribe-review <指摘URL>`で、指摘を理解する
        2. 追加で質問したりして、修正するべきかどうか、修正するとしたらどのような方針にするかを決める
        3. plan モードを用いて計画を作成して実行
        4. コミットを作成
            - https://github.com/openai/symphony/blob/main/.codex/skills/commit/SKILL.md を少し調整したものを使っているが、本リポジトリには入れていない


#### [codex/skills/pr-review](codex/skills/pr-review)

最終調整時期: GPT-6.2

現在のワークスペースにチェックアウトされているブランチに対応するGitHubのプルリクエストに対して、コードレビューを行います。

- ghコマンドが利用可能である必要があります
    - 対象PRの特定、関連課題の特定、PRのdiff取得に利用します
- 複数観点ごとに、サブエージェントを起動してレビューを行うため、トークンの消費量が結構大きいので注意してください
- [`lead-reviewer.toml`](codex/agents/lead-reviewer.toml) / [`focused-reviewer.toml`](codex/agents/focused-reviewer.toml)で定義されるサブエージェントを利用することを想定しています
    - 利用しなくても動作するようにSKILL.mdは書いていますが、調整などはしていません
    - 以下のような役割分担をする想定です
        - 弱いモデルを使った`focused-reviewer`によって、観点ごとにレビューを行う
        - 強いモデルを使った`lead-reviewer`によって観点ごとのレビュー結果を検証し、レビュー結果を生成する
- `run-pr-review`スキルを経由して実行されることを想定しています。

#### [codex/skills/run-pr-review](codex/skills/run-pr-review)

最終調整時期: GPT-6.2

- `pr-review`を実行するためのメタスキルです
- 新規にレビューの統括サブエージェントを起動して、そのサブエージェントに`pr-review`を利用させます。

#### [codex/skills/diff-review](codex/skills/diff-review)

最終調整時期: GPT-6.2

現在のワークスペースのdiffに対して、コードレビューを行います。
基本的な動作は、`pr-review`スキルと同様ですが、レビュー対象がプルリクエストのdiffではなく、指定した比較対象ベースコミットとのdiffになります。

比較対象には、コミット・ブランチ・タグを指定可能で、指定していなかった場合HEADが指定されたものとして取り扱います。

`/goal`の機能とともに使うことを想定して、作成したものです。
GitHubの課題を与えると、それを要件として、要件の充足をチェックします。

`implement-prepared-issue`スキルから参照されています。


#### [codex/skills/describe-review](codex/skills/describe-review)

最終調整時期: GPT-6.2

レビュー指摘に対して解説を行います。
解説に加えて以下を行います。

- 指摘の妥当性・修正の案の評価
- 問題への既存の言及があればその解説
- 別の修正案の提示
- 類似の問題の探索

`$describe-review <指摘URL>` / `$describe-review <指摘文字列>`などで利用できます。
対象の指摘を指摘しなかった場合、`run-pr-review`スキルが生成するファイルを読みに行きます。

#### [codex/skills/gen-pr-comment](codex/skills/gen-pr-comment)

指摘を元に、PRのレビューコメントをpending状態で作成します。

```
以下の指摘をPRコメントにしてください。

---

<指摘>
```

などのプロンプトで利用できます。


### 開発ワークフロー

1. `prepare-issue-for-goal`を繰り返して情報をissueに貯める
    - 繰り返す際には、基本的にはコンテキストをクリアする
2. `/goal ${課題URL}`が`implement-prepared-issue`を起動して実装を行う

というワークフローを想定したスキルです。
現状、`implement-prepared-issue`の実行時間とトークン消費が大きいので注意してください。

これは、以下の2点が原因です

- 内部で起動する`diff-review`のトークン消費と実行時間が長い
- `diff-review`と修正を繰り返すが、レビューが適切に収束しない


#### [codex/skills/prepare-issue-for-goal](codex/skills/prepare-issue-for-goal)

最終調整時期: GPT-6.1（ただし、diffが１万行以下程度の規模にしか、まだ使えていない）

指定されたGitHubのissueに対して、`implement-prepared-issue`で実装するための事前情報を決定し、コメントとして情報を追加します。

- ghコマンドが必要です
- plan modeで開始することを想定しています（選択肢の提示と入力UIが便利なので）



#### [codex/skills/implement-prepared-issue](codex/skills/implement-prepared-issue)

最終調整時期: GPT-6.1（ただし、diffが１万行以下程度の規模にしか、まだ使えていない）

課題に蓄積された情報をもとに、実際の実装を行います。
実装の完了後、コードレビューと修正を、修正が収束するまで繰り返します。

まだ試行錯誤中で高頻度で修正を行っており、安定していません。
以前、レビューと修正が収束せず、延々と動き続けたことがあり、その後調整しましたが同規模の実装には利用できていません。
