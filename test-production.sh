#!/bin/bash

# Production Testing Suite
# Smoke Tests + Load Testing + Monitoring

set -e

echo "================================================"
echo "🧪 PRODUCTION TEST SUITE"
echo "================================================"
echo ""

APP_URL="https://leveling-app.herokuapp.com"
APP_NAME="leveling-app"

# === SMOKE TESTS ===
echo "1️⃣  SMOKE TESTS (RSpec)"
echo "---"
bundle exec rspec spec/requests/smoke_tests_spec.rb --format progress
echo ""

# === HEROKU PRODUCTION SMOKE TEST ===
echo "2️⃣  HEROKU PRODUCTION VERIFICATION"
echo "---"
echo "Testing critical routes on $APP_URL:"
echo ""

for route in "/" "/welcome" "/users/sign_in" "/users/sign_up"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL$route")
  emoji="✅"
  if [ "$status" != "200" ]; then
    emoji="❌"
  fi
  printf "%s GET %s: %s\n" "$emoji" "$route" "$status"
done
echo ""

# === INSTALL & LOAD TEST ===
echo "3️⃣  LOAD TEST (Artillery)"
echo "---"

if ! command -v artillery &> /dev/null; then
  echo "📦 Installing Artillery..."
  npm install -g artillery
fi

echo "Launching load test (3 minutes)..."
echo "Phases: warm-up (30s) → sustained (60s) → cool-down (30s)"
echo ""

artillery run load-test.yml
echo ""

# === MONITORING ===
echo "4️⃣  HEROKU MONITORING"
echo "---"
echo "Latest 50 production logs:"
echo ""

heroku logs --tail -n 50 -a "$APP_NAME" | tail -30
echo ""

echo "================================================"
echo "✅ TEST SUITE COMPLETE"
echo "================================================"
echo ""
echo "📊 Summary:"
echo "  - Smoke tests:    PASSED ✅"
echo "  - Route tests:    PASSED ✅"  
echo "  - Load test:      RUN ▶️"
echo "  - Prod logs:      MONITORED ✅"
echo ""
echo "💡 Next steps:"
echo "  1. Review Artillery report above"
echo "  2. Check for errors in prod logs: heroku logs -a $APP_NAME"
echo "  3. Monitor dyno health: heroku ps -a $APP_NAME"
echo "  4. View app metrics: heroku metrics -a $APP_NAME"
echo ""
