#!/usr/bin/env bash
set -euo pipefail

service postgresql start

su postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'password';\""

su postgres -c "psql -tAc \"SELECT 1 FROM pg_database WHERE datname = 'leveling_app_development'\"" | grep -q 1 || su postgres -c "createdb leveling_app_development"
su postgres -c "psql -tAc \"SELECT 1 FROM pg_database WHERE datname = 'leveling_app_test'\"" | grep -q 1 || su postgres -c "createdb leveling_app_test"

bundle install
DATABASE_URL="postgresql://postgres:password@localhost:5432/leveling_app_development" bundle exec rails db:prepare
DATABASE_URL="postgresql://postgres:password@localhost:5432/leveling_app_development" TEST_DATABASE_URL="postgresql://postgres:password@localhost:5432/leveling_app_test" RAILS_ENV=test bundle exec rails db:prepare
