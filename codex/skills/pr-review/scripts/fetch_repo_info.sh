#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 <output_path>" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

output_path=$1
output_dir=$(dirname "$output_path")
mkdir -p "$output_dir"

tmp_file=$(mktemp "${output_path}.tmp.XXXXXX")
trap 'rm -f "$tmp_file"' EXIT

name_with_owner=$(gh repo view --json nameWithOwner -q .nameWithOwner)
pr_number=$(gh pr view --json number --jq '.number')

owner=${name_with_owner%%/*}
repo=${name_with_owner#*/}

jq -n \
  --arg owner "$owner" \
  --arg repo "$repo" \
  --arg nameWithOwner "$name_with_owner" \
  --argjson pullRequestNumber "$pr_number" \
  '{
    owner: $owner,
    repo: $repo,
    nameWithOwner: $nameWithOwner,
    pullRequestNumber: $pullRequestNumber
  }' >"$tmp_file"

mv "$tmp_file" "$output_path"
