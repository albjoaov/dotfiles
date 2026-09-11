#!/bin/bash

set -euo pipefail

PR_NUMBER="${1:?Usage: bash $0 <pr_number> <title>}"
TITLE="${2:?Usage: bash $0 <pr_number> <title>}"

if ! command -v gh &>/dev/null; then
	echo "Error: GitHub CLI (gh) is not installed!" >&2
	exit 1
fi

if ! command -v jq &>/dev/null; then
	echo "Error: jq is not installed!" >&2
	exit 1
fi

if ! gh auth status &>/dev/null; then
	echo "Error: GitHub CLI is not authenticated! Run: gh auth login" >&2
	exit 1
fi

BODY=$(cat)

REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')

jq -n --arg title "$TITLE" --arg body "$BODY" '{title: $title, body: $body}' |
	gh api "repos/${REPO}/pulls/${PR_NUMBER}" -X PATCH --input -
