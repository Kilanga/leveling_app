#!/usr/bin/env bash

# Full release script for Leveling App
# Usage: ./release.sh 1.2.1 [heroku-app]

set -euo pipefail

VERSION="${1:-}"
HEROKU_APP="${2:-${HEROKU_APP:-leveling-app}}"
CHANGELOG_FILE="CHANGELOG.md"
TODAY="$(date +%F)"

usage() {
  echo "Usage: ./release.sh <version> [heroku-app]"
  echo "Example: ./release.sh 1.2.1 leveling-app"
  echo "Default Heroku app: leveling-app (or HEROKU_APP env var)"
}

if [[ -z "$VERSION" ]]; then
  usage
  exit 1
fi

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: version must follow semantic versioning (e.g., 1.2.1)."
  exit 1
fi

if [[ ! -f "$CHANGELOG_FILE" ]]; then
  echo "Error: $CHANGELOG_FILE not found."
  exit 1
fi

if ! command -v heroku >/dev/null 2>&1; then
  echo "Error: Heroku CLI not found in PATH."
  exit 1
fi

if ! git diff-index --quiet HEAD --; then
  echo "Error: uncommitted changes detected. Commit/stash before releasing."
  exit 1
fi

if git rev-parse -q --verify "refs/tags/v$VERSION" >/dev/null; then
  echo "Error: tag v$VERSION already exists."
  exit 1
fi

echo "Starting release v$VERSION ($TODAY)"

tmp_file="$(mktemp)"
awk -v version="$VERSION" -v today="$TODAY" '
BEGIN {
  in_unreleased = 0
  captured_rest = 0
}
{
  if ($0 ~ /^## \[Non publi/) {
    found_unreleased = 1
    print
    print ""
    print "## [" version "] - " today
    print ""
    in_unreleased = 1
    next
  }

  if (in_unreleased == 1) {
    if ($0 ~ /^## \[/) {
      in_unreleased = 0
      captured_rest = 1
      print $0
      next
    }

    if ($0 !~ /^[[:space:]]*$/) {
      unreleased_has_content = 1
    }

    print
    next
  }

  print
}
END {
  if (found_unreleased != 1) {
    print "ERROR: missing section ## [Non publie]" > "/dev/stderr"
    exit 2
  }

  if (unreleased_has_content != 1) {
    print "ERROR: section ## [Non publie] is empty" > "/dev/stderr"
    exit 3
  }
}
' "$CHANGELOG_FILE" > "$tmp_file"

mv "$tmp_file" "$CHANGELOG_FILE"
echo "Updated $CHANGELOG_FILE with version $VERSION"

echo "Running RSpec..."
./bin/bundle exec rspec

echo "Running Rails test..."
./bin/bundle exec rails test

echo "Committing changelog..."
git add "$CHANGELOG_FILE"
git commit -m "docs: release v$VERSION"

echo "Tagging release..."
git tag -a "v$VERSION" -m "Version $VERSION

See CHANGELOG.md for details."

echo "Pushing branch and tag..."
git push origin master
git push origin "v$VERSION"

echo "Running Heroku migrations on $HEROKU_APP..."
heroku run bundle exec rails db:migrate -a "$HEROKU_APP"

echo "Restarting Heroku dynos..."
heroku ps:restart -a "$HEROKU_APP"

echo "Checking recent Heroku 500/auth errors..."
recent_log_scan="$(heroku logs -n 300 -a "$HEROKU_APP" | grep -Ei "Completed 500|UndefinedTable|Authentication failure|bytesize" || true)"
if [[ -n "$recent_log_scan" ]]; then
  echo "Warning: suspicious log lines found (showing tail):"
  echo "$recent_log_scan" | tail -n 20
else
  echo "No recent matching 500/auth error signatures found in the last 300 lines."
fi

echo "Release complete: v$VERSION"
echo "GitHub tag: https://github.com/Kilanga/leveling_app/releases/tag/v$VERSION"
