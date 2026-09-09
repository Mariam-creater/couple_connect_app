# COUPLE CONNECT – Production Deployment & DevOps Guide

This guide covers deploying the **Laravel 12 API backend**, **MySQL**, **Redis**, **WebSocket Reverb Engine**, and the **Flutter cross-platform client (Web, iOS, Android)**.

---

## 1. Backend Server Deployment (Docker Compose)

### Prerequisites
- Ubuntu 22.04 LTS / Debian 12
- Docker Engine 24.0+ & Docker Compose v2+
- Domain name with DNS A records pointing to server IP (e.g. `api.coupleconnect.app`)

### Step-by-Step Setup

1. **Clone repository on production server:**
   ```bash
   git clone https://github.com/your-org/couple_connect.git /var/www/couple_connect
   cd /var/www/couple_connect/backend
   ```

2. **Configure Environment Variables (`.env`):**
   ```ini
   APP_NAME="Couple Connect"
   APP_ENV=production
   APP_KEY=base64:YOUR_GENERATED_APP_KEY
   APP_DEBUG=false
   APP_URL=https://api.coupleconnect.app

   DB_CONNECTION=mysql
   DB_HOST=mysql
   DB_PORT=3306
   DB_DATABASE=couple_connect
   DB_USERNAME=couple_user
   DB_PASSWORD=YOUR_STRONG_DATABASE_PASSWORD

   REDIS_HOST=redis
   REDIS_PASSWORD=YOUR_STRONG_REDIS_PASSWORD
   REDIS_PORT=6379

   BROADCAST_CONNECTION=reverb
   REVERB_APP_ID=couple_connect_app
   REVERB_APP_KEY=couple_connect_key
   REVERB_APP_SECRET=couple_connect_secret
   REVERB_HOST="0.0.0.0"
   REVERB_PORT=8080
   REVERB_SCHEME=https

   GEMINI_API_KEY=YOUR_GOOGLE_GEMINI_API_KEY
   ```

3. **Launch Docker Services:**
   ```bash
   docker compose up -d --build
   ```

4. **Run Database Migrations & Initial Seeders:**
   ```bash
   docker compose exec app php artisan migrate --force
   docker compose exec app php artisan db:seed --class=CoupleConnectSeeder --force
   ```

5. **Setup Storage Symlink & Cache Optimization:**
   ```bash
   docker compose exec app php artisan storage:link
   docker compose exec app php artisan config:cache
   docker compose exec app php artisan route:cache
   docker compose exec app php artisan view:cache
   ```

---

## 2. Flutter Client Builds

### Web Application (PWA / Responsive SPA)
```bash
cd /var/www/couple_connect/frontend
flutter build web --release --pwa-strategy=offline-first
# Output directory: build/web
```

### Android APK & App Bundle (Google Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (Apple App Store)
```bash
flutter build ipa --release
# Output: build/ios/archive/Runner.xcarchive
```

---

## 3. SSL / HTTPS Setup with Certbot

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.coupleconnect.app -d app.coupleconnect.app
```

---

## 4. Cron Jobs & Queue Workers

Add to crontab (`crontab -e`):
```cron
* * * * * cd /var/www/couple_connect/backend && docker compose exec -T app php artisan schedule:run >> /dev/null 2>&1
```
