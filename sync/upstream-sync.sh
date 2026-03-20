#!/bin/bash
# Sync with upstream Omarchy and apply headless filters

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
OMARCHY_PATH="$REPO_ROOT"

echo "🔄 Syncing with upstream Omarchy..."

# Add upstream remote if not exists
cd "$OMARCHY_PATH"
git remote add upstream https://github.com/basecamp/omarchy.git 2>/dev/null || true

# Fetch upstream
echo "📥 Fetching upstream..."
git fetch upstream master

# Copy sync tools to temp dir BEFORE switching branches (they don't exist in upstream)
SYNC_TMP=$(mktemp -d)
cp -r "$SCRIPT_DIR"/* "$SYNC_TMP/"
EXCLUDE_PATTERNS=$(cat "$SYNC_TMP/exclude-patterns.txt")
trap 'rm -rf "$SYNC_TMP"' EXIT

# Create temp branch from upstream
TEMP_BRANCH="temp-upstream-$(date +%s)"
echo "🔀 Creating temp branch: $TEMP_BRANCH"
git checkout -b "$TEMP_BRANCH" upstream/master

# Apply exclusions
echo "🧹 Applying exclusions..."
while IFS= read -r pattern; do
  # Skip comments and empty lines
  [[ -z "$pattern" || "$pattern" =~ ^# ]] && continue
  
  # Remove matching files/directories
  if [[ "$pattern" == */ ]]; then
    # Directory pattern
    rm -rf "$OMARCHY_PATH/$pattern" 2>/dev/null && echo "  Removed dir: $pattern" || true
  elif [[ "$pattern" == *\** ]]; then
    # Glob pattern
    find "$OMARCHY_PATH" -path "$OMARCHY_PATH/$pattern" -delete 2>/dev/null && echo "  Removed: $pattern" || true
  else
    # Specific file
    rm -f "$OMARCHY_PATH/$pattern" 2>/dev/null && echo "  Removed: $pattern" || true
  fi
done <<< "$EXCLUDE_PATTERNS"

# Filter package lists
echo "📦 Filtering package lists..."
OMARCHY_PATH="$OMARCHY_PATH" python3 "$SYNC_TMP/filter-packages.py"

# Stage and commit
echo "💾 Committing filtered upstream..."
git add -A
git commit -m "Filtered upstream for headless $(date +%Y-%m-%d)" || echo "Nothing to commit"

# Checkout headless branch and merge
echo "🔀 Merging into dev branch..."
git checkout dev
MERGE_FAILED=false
git merge "$TEMP_BRANCH" --no-ff --allow-unrelated-histories -m "Sync with upstream $(date +%Y-%m-%d)" || MERGE_FAILED=true

if [[ $MERGE_FAILED == "true" ]]; then
  # Auto-resolve modify/delete conflicts (GUI files our filter removed from upstream)
  CONFLICTED=$(git diff --name-only --diff-filter=U)
  if [[ -n $CONFLICTED ]]; then
    echo "🔧 Auto-resolving modify/delete conflicts (deleted GUI files)..."
    while IFS= read -r file; do
      # If the file doesn't exist in the filtered upstream branch, delete it
      if ! git ls-tree --name-only "$TEMP_BRANCH" -- "$file" &>/dev/null; then
        git rm "$file" &>/dev/null
        echo "  Deleted: $file"
      fi
    done <<< "$CONFLICTED"
  fi

  # Check if there are still unresolved conflicts
  REMAINING=$(git diff --name-only --diff-filter=U)
  if [[ -n $REMAINING ]]; then
    echo "❌ Unresolved merge conflicts remain. Please resolve manually:"
    echo "$REMAINING"
    echo "Merge from: $TEMP_BRANCH"
    exit 1
  fi

  # All conflicts resolved, commit the merge
  git commit --no-edit
fi

# Clean up temp branch
git branch -D "$TEMP_BRANCH"

echo ""
echo "✅ Sync complete!"
echo "Review changes and push when ready:"
echo "  git push origin dev"
