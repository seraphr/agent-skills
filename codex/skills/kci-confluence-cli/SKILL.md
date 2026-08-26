---
name: kci-confluence-cli
description: Confluence v6.15.7 向けの kci-confluence-cli を利用し、Confluence ページ本文の取得・更新、content 情報取得、添付ファイルの取得・作成・削除、HTML から Confluence storage XML への変換を行う場合に利用します。
---

# kci-confluence-cli

## 基本方針

Confluence CLI を使うときは、インストール手順を案内せず、常に以下の形式で実行してください。

```bash
uvx --from kci-confluence-cli confluence ...
```

CLI の実コマンド名は `confluence` です。`uvx --from kci-confluence-cli` はパッケージ取得と実行のための接頭辞として扱います。

## 認証と接続

Confluence 接続情報は、次の環境変数または各コマンドのオプションで指定します。

- `CONFLUENCE_BASE_URL`: Confluence のベース URL
- `CONFLUENCE_USER_NAME`: Confluence のユーザー名
- `CONFLUENCE_USER_PASSWORD`: Confluence のパスワード

認証情報やパスワードをファイルに保存しないでください。コマンド例を提示するときは、実値ではなく環境変数名やプレースホルダーで表現してください。

## 作業手順

1. ユーザーの依頼内容から、読み取り操作か更新・削除操作かを判定してください。
2. 具体的なコマンド仕様が必要な場合は、`references/command-reference.md` を読んでください。
3. ページ更新や添付削除など Confluence 上の状態を変更する操作では、対象ページ ID、入力ファイル、変更内容、破壊的なオプションを確認してから実行してください。
4. ページ更新時は、可能なら事前に `page get_body` で現在の本文を取得し、更新後に差分や出力を確認してください。
5. CLI が対話確認を要求する可能性がある自動実行では、意図が明確な場合だけ `--yes` を使用してください。

## よく使う操作

- ページ本文を取得する: `page get_body`
- storage XML でページを更新する: `page update`
- content ID からページやブログなどの情報を取得する: `content get_by_id`
- 添付ファイル一覧を取得する: `attachment get`
- 添付ファイルをアップロードする: `attachment create`
- 添付ファイルを削除する: `attachment delete`
- HTML を Confluence storage XML に変換する: `local convert_html`

詳細な引数、例、注意点は `references/command-reference.md` を参照してください。
