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

### 2. Prepare CHANGELOG.md
Before creating a release, add your release notes under `## [Non publié]`:
- Use subsections: Added, Changed, Fixed, Removed, Deprecated
- Keep this section up to date while developing
- The release script automatically promotes this section to `## [X.Y.Z] - YYYY-MM-DD`

**Example:**
```markdown
## [1.2.1] - 2026-03-26
### Fixed
- Fix Google OAuth CSRF error

### Changed
- Redesign login page
```

### 3. Run Release Script
Use the release script to run tests, update changelog, commit, tag, push, and run Heroku migrations:

```bash
./release.sh 2.0.0 motivup-app
```

The script will:
- Move content from `## [Non publié]` to `## [1.2.1] - YYYY-MM-DD`
- Run `rspec` and `rails test`
- Commit `CHANGELOG.md`
- Create annotated tag `v1.2.1`
- Push `master` + tag
- Run `rails db:migrate` and restart dynos on Heroku

### 4. Manual Alternative (if needed)
If you need to release manually, you can still run the old flow:

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

- [ ] `CHANGELOG.md` has release notes under `## [Non publié]`
- [ ] Run release script: `./release.sh 2.0.0 motivup-app`
- [ ] Verify version bumping follows semver rules
- [ ] Verify on GitHub: https://github.com/Kilanga/motivup-app/releases

## GitHub Releases

GitHub automatically creates releases from git tags. Release notes are auto-populated from the tag message.

View all releases: https://github.com/Kilanga/motivup-app/releases
