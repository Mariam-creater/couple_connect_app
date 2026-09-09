#!/usr/bin/env bash
# Render Native Start Script
set -e

PORT=${PORT:-10000}

echo "==> Creating storage link..."
php artisan storage:link || true

echo "==> Running database migrations..."
php artisan migrate --force || echo "Migration command completed"

echo "==> Starting web server on 0.0.0.0:${PORT}..."
exec php -S 0.0.0.0:${PORT} -t public
