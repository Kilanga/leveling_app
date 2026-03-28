# Leveling App

## Prerequisites

- Ruby 3.3.11
- PostgreSQL (local or remote)

## Setup

1. Copy `.env.example` to `.env` and fill values.
2. Install dependencies:
	 - `./bin/bundle install`
3. Setup database:
	 - `./bin/rails db:create db:migrate`
4. Start server:
	 - `./bin/rails s`

## External Services

- Database:
	- Use `DATABASE_URL` for remote databases.
	- If no `DATABASE_URL`, app falls back to `DB_USERNAME`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`.
- Stripe:
	- Requires `STRIPE_PUBLIC_KEY` and `STRIPE_SECRET_KEY`.
	- Webhooks require `STRIPE_WEBHOOK_SECRET`.
- Google OAuth (Devise):
	- Requires `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`.
	- Callback URL to configure in Google Cloud Console:
	  - `https://your-domain.com/users/auth/google_oauth2/callback`
	  - Example Heroku: `https://leveling-app.herokuapp.com/users/auth/google_oauth2/callback`
- Cloudinary:
	- Requires `CLOUDINARY_URL`.
	- In development, app falls back to local storage if `CLOUDINARY_URL` is missing.
- SendGrid:
	- Requires `SENDGRID_API_KEY` in production.

## Tests

- `./bin/bundle exec rspec`

## Release

- Add release notes under `## [Non publié]` in `CHANGELOG.md`
- Run full release flow (tests + changelog versioning + tag + push + Heroku migrate/restart):
	- `./release.sh 1.2.1 leveling-app`

## Ruby 3.3 Migration Checklist

Local machine:
- Install Ruby 3.3.11 via your version manager (`rbenv`, `asdf`, `mise`).
- Select the project Ruby version from `.ruby-version`.
- Reinstall gems with `bundle install`.
- Run full checks: `bundle exec rspec`, `bin/brakeman`, `bundle exec bundle-audit check --update`.

GitHub Actions:
- Workflows use `ruby-version: .ruby-version`, so CI follows 3.3 automatically.
- Validate on first PR after migration that lint/tests/security jobs pass.

Heroku:
- Ruby buildpack resolves version from `Gemfile` and lockfile.
- Deploy after local re-lock on Ruby 3.3, then verify runtime with `heroku run ruby -v -a leveling-app`.
- Verify app boot + release migration logs after deploy.

Supabase/PostgreSQL:
- Ruby upgrade does not require PostgreSQL server upgrade by itself.
- Validate connectivity post-deploy with `heroku run "bundle exec rails db:migrate:status" -a leveling-app`.

End-to-end check:
- Run `./script/check_ruby33_readiness.sh leveling-app` to validate local Ruby, bundle health, Heroku Ruby runtime, and migration status.

Dev Container troubleshooting:
- If VS Code terminal still reports Ruby 3.2.x, rebuild the container (`Dev Containers: Rebuild Container`) to refresh the base image.
- Verify with `ruby -v` and ensure it starts with `3.3.11`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Commit message guidelines
- Semantic versioning rules
- Release and tag process
- Changelog format

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.
