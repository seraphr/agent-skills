# kci-confluence-cli Command Reference

この reference は https://confluence-cli.readthedocs.io/ja/latest/ の要点を、Codex が `uvx --from kci-confluence-cli confluence ...` 形式で使いやすいようにまとめたものです。

## 共通

基本形:

```bash
uvx --from kci-confluence-cli confluence <command> <subcommand> [options]
```

トップレベルのコマンド:

- `attachment`: 添付ファイルに関する操作
- `content`: content ID を使った情報取得
- `page`: ページまたはブログ本文の取得・更新
- `local`: ローカルファイル変換

共通オプション:

- `--debug`: デバッグログを出力する
- `--confluence_base_url`: Confluence のベース URL。未指定時は `CONFLUENCE_BASE_URL`
- `--confluence_user_name`: ユーザー名。未指定時は `CONFLUENCE_USER_NAME`
- `--confluence_user_password`: パスワード。未指定時は `CONFLUENCE_USER_PASSWORD`

## page get_body

ページまたはブログの本文を取得します。デフォルトは storage フォーマットです。

```bash
uvx --from kci-confluence-cli confluence page get_body --page_id "${PAGE_ID}" -o output.xml
```

主な引数:

- `-p, --page_id`: 取得対象のページまたはブログの ID
- `--representation`: `storage`, `view`, `editor`, `export_view`, `styled_view`, `anonymous_export_view` から指定。デフォルトは `storage`
- `-o, --output`: 出力先ファイル
- `--pretty`: HTML を整形して出力する

ページ更新前のバックアップ取得にも利用してください。

## page update

storage フォーマットの XML ファイルでページを更新します。

```bash
uvx --from kci-confluence-cli confluence page update \
  --page_id "${PAGE_ID}" \
  --xml_file page.xml \
  --comment "ページを更新しました"
```

主な引数:

- `-p, --page_id`: 更新対象のページまたはブログの ID
- `--xml_file`: storage フォーマット XML ファイル
- `--comment`: 更新コメント
- `--yes`: すべてのプロンプトに自動で yes と答える

注意:

- 更新前に `page get_body` で現在の storage XML を取得してください。
- `--yes` は非対話実行が必要で、対象と内容が明確な場合だけ使ってください。
- XML は Confluence storage フォーマットとして扱われます。

## content get_by_id

content ID からページなどの content 情報を取得します。

```bash
uvx --from kci-confluence-cli confluence content get_by_id --content_id "${CONTENT_ID}" -o content.json
```

主な引数:

- `-c, --content_id`: 取得対象の content ID
- `--expand`: 取得したいプロパティ。指定可能な値は出力結果の `_expandable` を参照
- `-o, --output`: 出力先ファイル

## attachment get

ページまたはブログに紐づく添付ファイル情報を取得します。

```bash
uvx --from kci-confluence-cli confluence attachment get --page_id "${PAGE_ID}" -o attachments.json
```

主な引数:

- `-p, --page_id`: 添付ファイルが存在するページまたはブログの ID
- `--filename`: ファイル名で絞り込む
- `--media_type`: Media-Type で絞り込む
- `--expand`: 取得したいプロパティ。指定可能な値は出力結果の `_expandable` を参照
- `-o, --output`: 出力先ファイル

## attachment create

ページまたはブログにファイルを添付します。

```bash
uvx --from kci-confluence-cli confluence attachment create \
  --page_id "${PAGE_ID}" \
  --file file1.txt file2.txt
```

ディレクトリ配下をアップロードする例:

```bash
uvx --from kci-confluence-cli confluence attachment create \
  --page_id "${PAGE_ID}" \
  --dir dir/ \
  --filename_pattern '*.png'
```

主な引数:

- `-p, --page_id`: アップロード先ページまたはブログの ID
- `--file`: アップロードするファイル。複数指定可能
- `--dir`: アップロードするディレクトリ
- `--mime_type`: ファイル名から MIME タイプを判別できない場合に指定
- `--allow_duplicated`: 同名ファイルが既に存在する場合に上書きする
- `--filename_pattern`: `--dir` 使用時、glob 形式のパターンに一致するファイルだけアップロードする

注意:

- `--file` と `--dir` はどちらか一方を指定します。
- 同名ファイルが存在する場合、`--allow_duplicated` を指定しないと 400 Error になります。
- 上書きが意図したものか、実行前に確認してください。

## attachment delete

ページまたはブログの添付ファイルを削除します。削除された添付ファイルは通常ゴミ箱に移動されます。

```bash
uvx --from kci-confluence-cli confluence attachment delete --page_id "${PAGE_ID}" --filename file1.txt
```

主な引数:

- `-p, --page_id`: 削除対象の添付ファイルが存在するページまたはブログの ID
- `--filename`: ファイル名で絞り込む
- `--media_type`: Media-Type で絞り込む
- `--purge`: ゴミ箱からも完全に削除する。復元不可

注意:

- `--filename` や `--media_type` を指定しない場合、対象ページの添付ファイルをまとめて削除する挙動になります。
- `--purge` は復元不能なので、ユーザーの明確な承認なしに使わないでください。

## local convert_html

HTML を Confluence storage XML に変換します。

```bash
uvx --from kci-confluence-cli confluence local convert_html input.html output.xml
```

引数:

- `input_html`: 変換元 HTML
- `output_xml`: 変換先 XML

注意:

- `<img src="foo.png">` のようなローカル画像参照は、Confluence 添付ファイル参照に変換されます。
- HTML 内の画像ファイルを Confluence で表示するには、ページ側に該当ファイルを添付する必要があります。
- `img` 要素の `src` 属性に含まれるディレクトリ部分は無視され、ファイル名で参照されます。
- Base64 Data URL 画像は Confluence storage XML 変換に対応していません。
