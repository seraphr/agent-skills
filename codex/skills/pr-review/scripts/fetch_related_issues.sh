#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 <owner> <repo> <pull_request_number> <output_path>" >&2
}

if [[ $# -ne 4 ]]; then
  usage
  exit 1
fi

owner=$1
repo=$2
pull_request_number=$3
output_path=$4

mkdir -p "$(dirname "$output_path")"

tmp_file=$(mktemp "${output_path}.tmp.XXXXXX")
refs_file=$(mktemp)
items_file=$(mktemp)
trap 'rm -f "$tmp_file" "$refs_file" "$items_file"' EXIT

gh pr view "$pull_request_number" -R "$owner/$repo" --json closingIssuesReferences >"$refs_file"

mapfile -t related_issue_numbers < <(jq -r '.closingIssuesReferences[].number' "$refs_file")

if [[ ${#related_issue_numbers[@]} -eq 0 ]]; then
  printf '[]\n' >"$tmp_file"
  mv "$tmp_file" "$output_path"
  exit 0
fi

>"$items_file"
for related_issue_number in "${related_issue_numbers[@]}"; do
  gh issue view "$related_issue_number" \
    -R "$owner/$repo" \
    --json number,title,body,labels,assignees,milestone,state,comments,url \
    >>"$items_file"
  printf '\n' >>"$items_file"
done

jq -s '.' "$items_file" >"$tmp_file"

mv "$tmp_file" "$output_path"
