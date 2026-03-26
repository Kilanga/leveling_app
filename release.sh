#!/bin/bash

# Release script for Leveling App
# Usage: ./release.sh 1.2.1

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./release.sh <version>"
  echo "Example: ./release.sh 1.2.1"
  exit 1
fi

if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must follow semantic versioning (e.g., 1.2.1)"
  exit 1
fi

echo "Releasing version $VERSION..."

# Verify all tests pass
echo "Running tests..."
./bin/bundle exec rspec || { echo "Tests failed!"; exit 1; }

# Verify git status
if ! git diff-index --quiet HEAD --; then
  echo "Error: Uncommitted changes. Please commit or stash them first."
  exit 1
fi

# Create tag
echo "Creating tag v$VERSION..."
git tag -a "v$VERSION" -m "Version $VERSION

See CHANGELOG.md for details."

# Push
echo "Pushing to GitHub..."
git push origin master
git push origin "v$VERSION"

echo "✓ Released version $VERSION"
echo "View on GitHub: https://github.com/Kilanga/leveling_app/releases/tag/v$VERSION"
