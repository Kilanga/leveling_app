# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.7] - 2026-03-26

### Fixed
- Weekly quests are now global/shared across all users instead of being user-specific

### Changed
- Dashboard now ensures one active global weekly quest and links each user to that same quest

## [1.2.6] - 2026-03-26

### Added
- Auto-create a weekly quest for users when none is currently active

### Changed
- Move "Quetes en cours" and "Quetes hebdomadaires" to the top of the dashboard
- Integrate the Kiviat chart directly in the page flow (without dedicated card container)

## [1.2.5] - 2026-03-26

### Added
- Add a Kiviat (radar) progression chart on the dashboard by quest category

### Changed
- Use embedded dashboard stats data for the chart instead of extra JSON fetch calls
- Refine chart visuals and tooltips for level and XP readability

## [1.2.4] - 2026-03-26

### Added
- Add a "Signaler un bug" button on the dashboard linking to GitHub Issues

### Changed
- Temporarily remove avatar and bundle offers from the shop interface
- Keep the shop focused on title purchases and equipment actions

## [1.2.3] - 2026-03-26

### Added
- Enforce profile completion after first Google OAuth signup (pseudo + avatar required)
- Add dedicated profile completion page for Google users before entering the app
- Add `profile_completed` flag on users to track onboarding state
- Add equip flow for owned cosmetic avatars directly from the shop
- Add active cosmetic avatar support on users (`active_avatar_item_id`)
- Add rarity-based cosmetic bundles (title + avatar) with discounted coin price

### Fixed
- Resolve OmniAuth CSRF/authenticity failures in production request phase
- Ensure OAuth submit form fully bypasses Turbo at form level
- Prevent invalid or tampered bundle purchases by server-side bundle validation

### Changed
- Remove non-essential authentication flash messages (success/info noise)
- Keep authentication feedback focused on actionable warnings/errors
- Redesign shop Titles/Avatars section with stronger rarity framing and ownership states
- Add direct "Equiper" actions for owned titles and avatars to increase cosmetic value
- Display equipped cosmetic avatars in profile and leaderboard views
- Highlight bundle savings in the shop to improve purchase intent

## [1.2.2] - 2026-03-27
### Fixed
- Fix OmniAuth route 404 error by changing link method from GET to POST
- Ensure OmniAuth button properly initializes POST request to `/users/auth/google_oauth2`

### Changed
- Remove gradient background from login and signup pages
- Replace purple gradient (667eea → 764ba2) with clean light background (`bg-light`)
- Refine auth page styling while maintaining modern card-based design and responsiveness
- Update Google OAuth button to use `button_to` with proper POST method and data-turbo: false

### UI Improvements
- Add Google logo SVG to OAuth authentication button
- Improve button accessibility with proper semantic HTML (button instead of anchor)
- Maintain card layout, spacing, and typography improvements from v1.2.1
- Keep avatar selection UI and form styling on signup page

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
