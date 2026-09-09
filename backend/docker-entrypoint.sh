#!/usr/bin/env sh
set -e

# Replace __PORT__ in nginx.conf with Render's assigned $PORT (default 10000)
RENDER_PORT=${PORT:-10000}
sed -i "s/__PORT__/${RENDER_PORT}/g" /etc/nginx/nginx.conf

echo "==> Preparing storage link and Laravel optimizations..."
php artisan storage:link || true
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run database migrations safely
if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
    echo "==> Executing database migrations (--force)..."
    php artisan migrate --force || echo "==> Note: Migrations skipped or database connecting..."
fi

echo "==> Launching PHP-FPM daemon..."
php-fpm -D

echo "==> Starting Nginx on port ${RENDER_PORT}..."
exec nginx -g "daemon off;"
