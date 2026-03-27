# Leveling App

## Prerequisites

- Ruby 3.2.x
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

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Commit message guidelines
- Semantic versioning rules
- Release and tag process
- Changelog format

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.
