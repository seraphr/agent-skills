#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 <owner> <repo> <issue_id> <output_path>" >&2
}

if [[ $# -ne 4 ]]; then
  usage
  exit 1
fi

owner=$1
repo=$2
issue_id=$3
output_path=$4

mkdir -p "$(dirname "$output_path")"

tmp_file=$(mktemp "${output_path}.tmp.XXXXXX")
trap 'rm -f "$tmp_file"' EXIT

gh pr diff "$issue_id" -R "$owner/$repo" >"$tmp_file"

mv "$tmp_file" "$output_path"
