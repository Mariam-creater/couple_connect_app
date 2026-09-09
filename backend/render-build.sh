#!/usr/bin/env bash
# Render Native Build Script
set -e

echo "==> Installing Composer Dependencies (Production)..."
composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

echo "==> Caching Laravel Configuration, Routes, and Views..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
