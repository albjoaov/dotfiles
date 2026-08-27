#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
	echo -e "${RED}Error: $1${NC}" >&2
}

print_success() {
	echo -e "${GREEN}$1${NC}"
}

print_info() {
	echo -e "${YELLOW}$1${NC}"
}

# Check if gh CLI is installed
if ! command -v gh &>/dev/null; then
	print_error "GitHub CLI (gh) is not installed!"
	echo ""
	echo "Installation instructions:"
	echo ""
	echo "  macOS (using Homebrew):"
	echo "    brew install gh"
	echo ""
	echo "  Or download from: https://cli.github.com/"
	echo ""
	echo "After installation, authenticate with: gh auth login"
	exit 1
fi

# Check if gh is authenticated
if ! gh auth status &>/dev/null; then
	print_error "GitHub CLI is not authenticated!"
	echo ""
	echo "Please authenticate with: gh auth login"
	exit 1
fi

# Get branch name (use provided argument or current branch)
BRANCH=${1:-$(git branch --show-current)}

if [ -z "$BRANCH" ]; then
	print_error "Could not determine branch name. Please provide a branch name as an argument."
	echo "Usage: $0 [branch-name]"
	exit 1
fi

# Check if branch is pushed to remote
if ! git rev-parse --verify "origin/$BRANCH" &>/dev/null; then
	print_error "Branch '$BRANCH' is not pushed to remote!"
	echo ""
	echo "Please push the branch first:"
	echo "  git push -u origin $BRANCH"
	echo ""
	exit 1
fi

# Check if local branch is up to date with remote (warning only)
LOCAL_COMMIT=$(git rev-parse "$BRANCH" 2>/dev/null || echo "")
REMOTE_COMMIT=$(git rev-parse "origin/$BRANCH" 2>/dev/null || echo "")

if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
	print_info "Warning: Local branch '$BRANCH' is not in sync with remote."
	echo "Consider pushing your local commits:"
	echo "  git push origin $BRANCH"
	echo ""
fi

# Check if PR exists for the branch
PR_NUMBER=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number' 2>/dev/null || echo "")

if [ -z "$PR_NUMBER" ]; then
	print_info "Creating PR for branch '$BRANCH'..."

	# Get the default base branch
	BASE_BRANCH=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')

	# Create PR in draft mode (GitHub will set title/body from commits)
	gh pr create --head "$BRANCH" --base "$BASE_BRANCH" --fill --draft

	# Get the newly created PR number
	PR_NUMBER=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number')

	if [ -z "$PR_NUMBER" ]; then
		print_error "Failed to create PR"
		exit 1
	fi

	print_success "PR #$PR_NUMBER created successfully"
	echo ""
else
	print_info "Found existing PR #$PR_NUMBER for branch '$BRANCH'"
	echo ""
fi

PR_URL=$(gh pr view "$PR_NUMBER" --json url --jq '.url')
echo "PR_METADATA_NUMBER=${PR_NUMBER}"
echo "PR_METADATA_URL=${PR_URL}"
echo ""

# Get and display the PR diff
gh pr diff "$PR_NUMBER"
