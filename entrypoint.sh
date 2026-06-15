#!/bin/sh
set -e

# Run any pending migrations before starting the server.
# This is a no-op if the database is already up to date.
bundle exec rails db:migrate

exec "$@"
