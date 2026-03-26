# Contributing Guidelines

## Version Management

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** (x.0.0): Breaking changes
- **MINOR** (0.x.0): New features (backward compatible)
- **PATCH** (0.0.x): Bug fixes (backward compatible)

## Commit & Release Process

### 1. Make Changes
Work on your feature or fix and commit your changes normally:
```bash
git add .
git commit -m "feat: Add new feature" # or fix:, docs:, etc.
```

### 2. Update CHANGELOG.md
Before creating a release, update `CHANGELOG.md`:
- Move items from `[Unreleased]` section to a new version section
- Follow the format: `## [X.Y.Z] - YYYY-MM-DD`
- Use subsections: Added, Changed, Fixed, Removed, Deprecated

**Example:**
```markdown
## [1.2.1] - 2026-03-26
### Fixed
- Fix Google OAuth CSRF error

### Changed
- Redesign login page
```

### 3. Create Version Tag
After updating CHANGELOG.md, create a git tag with release notes:

```bash
git add CHANGELOG.md
git commit -m "docs: Update CHANGELOG for v1.2.1"
git tag -a v1.2.1 -m "Version 1.2.1: Bug fixes and UI improvements

- Fix Google OAuth CSRF error
- Redesign login and signup pages
- Improve form styling and responsiveness"
git push origin master
git push origin v1.2.1
```

## Commit Message Format

Use conventional commits for clarity:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (formatting, missing semicolons, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Code change that improves performance
- **test**: Adding/updating tests
- **chore**: Changes to dependencies, tooling, CI/CD

### Examples
```bash
git commit -m "feat: Add Google OAuth integration"
git commit -m "fix: Resolve CSRF error in OmniAuth flow"
git commit -m "docs: Update README with OAuth setup instructions"
git commit -m "perf: Optimize N+1 queries in leaderboard"
```

## Release Checklist

Before releasing a new version:

- [ ] All tests pass locally: `./bin/bundle exec rspec`
- [ ] Update `CHANGELOG.md` with new changes
- [ ] Verify version bumping follows semver rules
- [ ] Commit changelog changes
- [ ] Create annotated git tag with descriptive message
- [ ] Push commits: `git push origin master`
- [ ] Push tag: `git push origin v1.2.1`
- [ ] Verify on GitHub: https://github.com/Kilanga/leveling_app/releases

## GitHub Releases

GitHub automatically creates releases from git tags. Release notes are auto-populated from the tag message.

View all releases: https://github.com/Kilanga/leveling_app/releases
