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

## Changelog

### v1.2.0 (2026-03-26)
- **FEATURE**: Add Google OAuth integration via Devise OmniAuth
  - Users can now sign up and log in with their Google account
  - Auto-generates `pseudo` and assigns default avatar on first Google login
  - Requires `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` env vars
  - OAuth callback URL: `/users/auth/google_oauth2/callback`
- **FEATURE**: Add Supabase Postgres Best Practices Agent Skill
- **FIX**: Use Supabase IPv4 pooler endpoint (`aws-1-eu-north-1.pooler.supabase.com:6543`) for Heroku compatibility

### v1.1.2 (2026-03-26)
- **FEATURE**: Add Stripe webhook + idempotent purchase fulfillment
- **FEATURE**: Add purchase confirmation emails via Action Mailer
- **FIX**: Security dependency updates (Rails, Devise, Nokogiri, Rack)
