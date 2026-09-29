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
tmp_index=$(mktemp "$(git rev-parse --show-toplevel)/tmp-index_XXXXXX")
trap 'rm -f "$tmp_index"' EXIT
GIT_INDEX_FILE="$tmp_index" git read-tree HEAD
GIT_INDEX_FILE="$tmp_index" git add -A -- ':(top,exclude).agent/temp' ':(top,glob,exclude)tmp-index_*'
GIT_INDEX_FILE="$tmp_index" git --no-pager diff --no-color --cached "$target_commit" > "$output_path"
