#!/usr/bin/env bash
set -e


# Remove old files
rm -f build/html/searchable.js
rm -f build/html/sortable.js
rm -f build/html/activity-data-table.json
rm -f build/html/segment-data-table.json
rm -f build/charts/chart-yearly-riding-stats.json
rm -f build/charts/chart-yearly-riding-stats.svg

# Make sure database and migration directories exist
mkdir -p database
mkdir -p migrations

# Delete install files
rm -Rf files/install
rm -Rf files/maps
# Delete test suite
rm -Rf tests
rm -Rf config/container_test.php

composer install --prefer-dist

# Run migrations.
rm -Rf database/db.strava-read
bin/doctrine-migrations migrate --no-interaction

# Update strava stats.
bin/console app:strava:import-data
bin/console app:strava:build-files

# Vacuum database
bin/console app:strava:vacuum

# Generate charts
npm ci
node echart.js

# Push changes
git add .
git status
git diff --staged --quiet || git commit -m"Updated strava activities"
git push
