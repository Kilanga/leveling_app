#!/usr/bin/env bash
set -euo pipefail

EXPECTED_RUBY_PREFIX="3.3.11"
CURRENT_RUBY="$(ruby -e 'print RUBY_VERSION')"
if [[ "${CURRENT_RUBY}" != ${EXPECTED_RUBY_PREFIX}* ]]; then
	echo "ERROR: expected Ruby ${EXPECTED_RUBY_PREFIX}.x in devcontainer, got ${CURRENT_RUBY}."
	echo "Rebuild the devcontainer to pick up the updated base image."
	exit 1
fi

service postgresql start

su postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'password';\""

su postgres -c "psql -tAc \"SELECT 1 FROM pg_database WHERE datname = 'leveling_app_development'\"" | grep -q 1 || su postgres -c "createdb leveling_app_development"
su postgres -c "psql -tAc \"SELECT 1 FROM pg_database WHERE datname = 'leveling_app_test'\"" | grep -q 1 || su postgres -c "createdb leveling_app_test"

bundle install
DATABASE_URL="postgresql://postgres:password@localhost:5432/leveling_app_development" bundle exec rails db:prepare
DATABASE_URL="postgresql://postgres:password@localhost:5432/leveling_app_development" TEST_DATABASE_URL="postgresql://postgres:password@localhost:5432/leveling_app_test" RAILS_ENV=test bundle exec rails db:prepare
