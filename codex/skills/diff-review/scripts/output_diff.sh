#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <target-commit> <output-path>" >&2
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

target_commit=$1
output_path=$2

# 環境変数を変更する前に、既存オブジェクトの保存先を取得します。
original_object_directory=$(
  git rev-parse --path-format=absolute --git-path objects
)

temporary_directory=$(mktemp -d "${TMPDIR:-/tmp}/diff-review.XXXXXX")
trap 'rm -rf -- "$temporary_directory"' EXIT

mkdir -p "$temporary_directory/objects"

export GIT_INDEX_FILE="$temporary_directory/index"
export GIT_OBJECT_DIRECTORY="$temporary_directory/objects"

# 既存の参照先も保持します。
export GIT_ALTERNATE_OBJECT_DIRECTORIES="$original_object_directory${GIT_ALTERNATE_OBJECT_DIRECTORIES:+:$GIT_ALTERNATE_OBJECT_DIRECTORIES}"

git read-tree HEAD
git add -A -- \
  ':(top,exclude).agent/temp/*' \
  ':(top,glob,exclude)tmp-index_*'
git --no-pager diff --no-color --cached "$target_commit" > "$output_path"