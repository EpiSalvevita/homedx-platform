#!/bin/sh
set -e

echo "Running Prisma migrations..."
./node_modules/.bin/prisma migrate deploy

if [ "${HOMEDX_SEED_DOCTORS:-false}" = "true" ]; then
  echo "Seeding demo doctors (safe to re-run)..."
  npm run seed:doctors || echo "Doctor seed skipped or already applied."
fi

exec "$@"
