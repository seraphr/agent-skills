#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 <issue_url>" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

issue_url=$1
echo "====== Issue 本文 ======"
gh issue view "$issue_url"

echo ""
echo "====== Issue コメント ======"
gh issue view "$issue_url" --comments