# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1] - 2026-03-26
### Fixed
- Fix Google OAuth CSRF error by changing OmniAuth request method from POST to GET
- Ensure OmniAuth route uses GET for initial authorization phase

### Changed
- Redesign login page (`/users/sign_in`) with modern gradient background and card-based layout
- Redesign signup page (`/users/sign_up`) with improved avatar selection UI and interactive cards
- Improve form spacing and typography for better readability
- Style OAuth buttons consistently across all authentication pages
- Add responsive design improvements for mobile and desktop views

### UI Improvements
- Add divider with "or" separator between form and OAuth options
- Implement modern Bootstrap 5 styling with gradient background (667eea → 764ba2)
- Add hover effects and visual feedback on interactive elements
- Improve avatar selection with badges (Guerrier/Guerrière) and transition effects

## [1.2.0] - 2026-03-26
### Added
- Google OAuth integration via Devise OmniAuth
  - Users can now sign up and log in with their Google account
  - Auto-generates `pseudo` and assigns default avatar on first Google login
  - Requires `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` environment variables
  - OAuth callback URL: `/users/auth/google_oauth2/callback`
- Supabase Postgres Best Practices Agent Skill
- Test coverage for Google OAuth user creation flow

### Fixed
- Use Supabase IPv4 pooler endpoint (`aws-1-eu-north-1.pooler.supabase.com:6543`) for Heroku compatibility
- Resolve IPv6-only database connectivity issues on Heroku dynos

## [1.1.2] - 2026-03-26
### Added
- Stripe webhook endpoint with signature verification for payment events
- Idempotent purchase fulfillment service using transaction IDs
- Purchase confirmation emails via Action Mailer

### Fixed
- Security dependency updates for Rails, Devise, Nokogiri, and Rack gems
- Address Dependabot vulnerabilities

## [1.1.1] - 2026-03-25
### Added
- Supabase Agent Skills installation support

### Changed
- Improved database configuration documentation

## [1.1.0] - 2026-03-25
### Added
- Comprehensive codebase refactoring with service objects
- Centralized XP and badge awarding logic via service classes
- DB integrity constraints and indexed queries
- Responsive UI improvements for mobile and desktop

### Fixed
- XP duplication issues across different quest completion paths
- N+1 query problems in leaderboard and friends controllers
- Purchase flow authorization and idempotency

## [1.0.0] - 2026-03-15
### Added
- Initial Rails 8 application setup
- Devise authentication with email confirmation
- Quest, user quest, and weekly quest systems
- XP and leveling mechanics
- Friendship system with status tracking
- Stripe payment integration
- Cloudinary image storage
- Admin dashboard for quest management
- Leaderboard and statistics pages
