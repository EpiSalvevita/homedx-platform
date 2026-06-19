#!/bin/sh
set -e

echo "Running Prisma migrations..."
npx prisma migrate deploy

if [ "${HOMEDX_SEED_DOCTORS:-true}" = "true" ]; then
  echo "Seeding demo doctors (safe to re-run)..."
  npm run seed:doctors || echo "Doctor seed skipped or already applied."
fi

exec "$@"
