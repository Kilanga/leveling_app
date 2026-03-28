#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${1:-leveling-app}"
EXPECTED_RUBY_PREFIX="3.3"

echo "== Local runtime =="
LOCAL_RUBY="$(ruby -e 'print RUBY_VERSION')"
echo "Ruby: ${LOCAL_RUBY}"
if [[ "${LOCAL_RUBY}" != ${EXPECTED_RUBY_PREFIX}* ]]; then
  echo "ERROR: local Ruby must start with ${EXPECTED_RUBY_PREFIX}."
  exit 1
fi

echo "== Bundle check =="
bundle check >/dev/null
echo "OK"

echo "== Heroku runtime =="
HEROKU_RUBY="$(heroku run "ruby -e 'print RUBY_VERSION'" -a "${APP_NAME}" 2>/dev/null | tail -n 1 | tr -d '\r')"
echo "Ruby: ${HEROKU_RUBY}"
if [[ "${HEROKU_RUBY}" != ${EXPECTED_RUBY_PREFIX}* ]]; then
  echo "ERROR: Heroku Ruby must start with ${EXPECTED_RUBY_PREFIX}."
  exit 1
fi

echo "== Heroku migration status =="
heroku run "bundle exec rails db:migrate:status" -a "${APP_NAME}" | tail -n 120

echo "== Result =="
echo "Ruby 3.3 readiness checks passed for local + Heroku."
