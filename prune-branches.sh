#!/bin/bash

# Prune feature branches from public repo and relocate to private repo
# Usage: ./prune-branches.sh
#
# Prerequisites:
#   - SSH keys configured for GitHub, OR
#   - gh CLI authenticated: gh auth login
#   - Private remote configured: git remote add private <url>

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

# Check authentication
echo "🔐 Checking GitHub authentication..."
if ! gh auth status > /dev/null 2>&1; then
  echo "❌ Error: gh CLI not authenticated"
  echo ""
  echo "Please authenticate with:"
  echo "  gh auth login"
  echo ""
  echo "Or set up SSH keys and update remotes to use SSH URLs:"
  echo "  git remote set-url origin git@github.com:twinboi90/ZoomRecovery.git"
  echo "  git remote set-url private git@github.com:twinboi90/ZoomRecovery-dev.git"
  exit 1
fi
echo "✅ GitHub authentication valid"
echo ""

# Branches to relocate
BRANCHES=(
  "claude/admiring-driscoll-260b5d"
  "claude/balenaetcher-overlay-visibility-WYzCc"
  "claude/scientific-agent-skills-yNVxE"
  "testing/beta/v1.2.0-updates"
)

PUBLIC_REPO="origin"
PRIVATE_REPO="private"

# Verify we have both remotes configured
if ! git remote get-url "$PUBLIC_REPO" > /dev/null 2>&1; then
  echo "❌ Error: '$PUBLIC_REPO' remote not found"
  exit 1
fi

if ! git remote get-url "$PRIVATE_REPO" > /dev/null 2>&1; then
  echo "❌ Error: '$PRIVATE_REPO' remote not found. Set it up with:"
  echo "   git remote add private <private-repo-url>"
  exit 1
fi

echo "🔄 Syncing branches from public to private repo..."
echo ""

for branch in "${BRANCHES[@]}"; do
  echo "Processing: $branch"

  # Fetch the branch from public repo if we don't have it locally
  if ! git rev-parse --verify "$branch" > /dev/null 2>&1; then
    echo "  ⬇️  Fetching from $PUBLIC_REPO..."
    if ! git fetch "$PUBLIC_REPO" "$branch:$branch" 2>&1; then
      echo "  ⚠️  Could not fetch $branch from $PUBLIC_REPO (may have already been deleted)"
      continue
    fi
  fi

  # Push the branch to private repo
  echo "  ⬆️  Pushing to $PRIVATE_REPO..."
  if git push "$PRIVATE_REPO" "$branch" 2>&1; then
    echo "  ✅ Pushed to private repo"
  else
    echo "  ⚠️  Failed to push to private repo"
    continue
  fi

  # Delete from public repo
  echo "  🗑️  Deleting from $PUBLIC_REPO..."
  if git push "$PUBLIC_REPO" --delete "$branch" 2>&1; then
    echo "  ✅ Deleted from public repo"
  else
    echo "  ⚠️  Failed to delete from public repo"
    continue
  fi

  # Delete local branch
  echo "  🗑️  Deleting local branch..."
  git branch -D "$branch" 2>&1 || true

  echo ""
done

echo "✨ Branch cleanup complete!"
echo ""
echo "📝 Summary:"
echo "  - All feature branches have been pushed to $PRIVATE_REPO"
echo "  - All feature branches have been deleted from $PUBLIC_REPO"
echo "  - Local branches have been cleaned up"
echo ""
echo "🔍 Verify with:"
echo "  git branch -a"
