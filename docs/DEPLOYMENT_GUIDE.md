# Couple Connect: Render Deployment Guide (Free Tier Optimized)

This guide walks you through deploying the **Couple Connect Laravel 12 Backend** to **Render.com**, configuring **Real-Time WebSockets via Pusher Channels**, setting up **Persistent Media Storage via Cloudflare R2 / S3**, and connecting **Physical Android/iOS Flutter Devices**.

---

## 1. Architecture Overview

```
                      ┌─────────────────────────────────┐
                      │   Flutter Mobile/Web Clients    │
                      │  (Device A  ◄═══►  Device B)    │
                      └───────┬─────────────────▲───────┘
                              │ HTTPS           │ WSS (Pusher Cloud Cluster)
                              ▼                 │
     ┌──────────────────────────────────────────┴─────────────────────────┐
     │                      Render.com Web Service                        │
     │                                                                    │
     │  ┌─────────────────────────┐         ┌──────────────────────────┐  │
     │  │  Laravel 12 REST API    │         │  Pusher Channels Cloud   │  │
     │  │  - Nginx + PHP-FPM      │────────►│  - Zero Server Overhead  │  │
     │  │  - E2EE Chat & Voice    │ Events  │  - Instant WSS Delivery  │  │
     │  │  - Auto-Cache & Migrates│         │  - 200k msgs/day (Free)  │  │
     │  └───────────┬─────────────┘         └──────────────────────────┘  │
     │              │                                                     │
     │              │ MySQL TCP (Port 3306)                               │
     │              ▼                                                     │
     │  ┌─────────────────────────┐                                       │
     │  │  Render / Cloud MySQL   │                                       │
     │  └─────────────────────────┘                                       │
     └──────────────────────┬─────────────────────────────────────────────┘
                            │
                            ▼
     ┌────────────────────────────────────────────────────────────────────┐
     │         Cloudflare R2 / AWS S3 Persistent Storage                  │
     │  - Encrypted Voice Notes (.m4a/.aac/.wav)                          │
     │  - Documents (PDF, DOCX, ZIP) & Memory Vault Photos                │
     │  - Free Egress Bandwidth & Instant Worldwide CDN Streaming         │
     └────────────────────────────────────────────────────────────────────┘
```

---

## 2. Deploying Backend to Render.com

### Step A: Push Code to GitHub / GitLab
Make sure your repository has the `backend/Dockerfile`, `backend/nginx.conf`, and `backend/docker-entrypoint.sh` files.

### Step B: Create a Web Service on Render
1. Log in to [dashboard.render.com](https://dashboard.render.com).
2. Click **New +** -> **Web Service**.
3. Select your GitHub repository (`couple_connect_app` or your repo).
4. Configure service settings:
   - **Name**: `couple-connect-backend`
   - **Region**: Choose closest to you (e.g., `Frankfurt`, `Oregon`, `Singapore`)
   - **Root Directory**: `backend`
   - **Environment**: `Docker`
   - **Plan**: `Free`

*(Alternatively, if using Render's Native PHP Environment without Docker:)*
- **Build Command**: `./render-build.sh` (or `composer install --no-dev --optimize-autoloader && php artisan config:cache && php artisan route:cache && php artisan view:cache`)
- **Start Command**: `./render-start.sh` (or `php artisan migrate --force && php artisan storage:link && php -S 0.0.0.0:$PORT -t public`)

---

## 3. Environment Variables Configuration for Render

In your Render Service dashboard, go to the **Environment** tab and add the following variables:

| Key | Example / Description |
|---|---|
| `APP_NAME` | `"Couple Connect"` |
| `APP_ENV` | `production` |
| `APP_KEY` | `base64:...` *(Generate via `php artisan key:generate --show`)* |
| `APP_DEBUG` | `false` |
| `APP_URL` | `https://couple-connect-backend.onrender.com` *(Your Render URL)* |
| `DB_CONNECTION` | `mysql` |
| `DB_HOST` | `your-db-host.com` *(Render MySQL / Aiven / Supabase / PlanetScale)* |
| `DB_PORT` | `3306` |
| `DB_DATABASE` | `couple_connect` |
| `DB_USERNAME` | `your_db_username` |
| `DB_PASSWORD` | `your_db_password` |
| `BROADCAST_CONNECTION` | `pusher` |
| `PUSHER_APP_ID` | `YOUR_PUSHER_APP_ID` |
| `PUSHER_APP_KEY` | `YOUR_PUSHER_APP_KEY` |
| `PUSHER_APP_SECRET` | `YOUR_PUSHER_APP_SECRET` |
| `PUSHER_APP_CLUSTER` | `eu` *(or `us2`, `mt1`, `ap1` depending on your Pusher app)* |
| `PUSHER_SCHEME` | `https` |
| `PUSHER_PORT` | `443` |
| `FILESYSTEM_DISK` | `s3` |
| `AWS_ACCESS_KEY_ID` | `YOUR_R2_ACCESS_KEY_ID` |
| `AWS_SECRET_ACCESS_KEY` | `YOUR_R2_SECRET_ACCESS_KEY` |
| `AWS_DEFAULT_REGION` | `auto` |
| `AWS_BUCKET` | `couple-connect-media` |
| `AWS_USE_PATH_STYLE_ENDPOINT` | `true` |
| `AWS_ENDPOINT` | `https://<YOUR_CF_ACCOUNT_ID>.r2.cloudflarestorage.com` |
| `AWS_URL` | `https://media.yourdomain.com` *(or public R2 `.r2.dev` bucket URL)* |
| `QUEUE_CONNECTION` | `database` |
| `CACHE_STORE` | `database` |
| `SESSION_DRIVER` | `database` |
| `RUN_MIGRATIONS` | `true` |

---

## 4. Real-Time WebSockets via Pusher Channels

Using Pusher Channels eliminates the need to run background WebSockets daemons (like Reverb) on Render's Free tier:

1. Create a free account at [pusher.com](https://pusher.com).
2. Click **Create app** -> Name: `couple-connect` -> Select cluster (e.g. `eu` or `us2`).
3. Under **App Keys**, copy `app_id`, `key`, `secret`, and `cluster`.
4. Enter them in the Render Environment Variables (`PUSHER_APP_ID`, `PUSHER_APP_KEY`, etc.).
5. Flutter clients connect securely over WSS (Port 443) with Sanctum token authentication at `${APP_URL}/api/v1/broadcasting/auth`.

---

## 5. Cloudflare R2 Persistent Storage Setup

Cloudflare R2 provides S3-compatible, zero-egress-fee storage that persists across Render container restarts:

1. In [dash.cloudflare.com](https://dash.cloudflare.com), navigate to **R2**.
2. Click **Create bucket** -> Name: `couple-connect-media`.
3. In **Manage R2 API Tokens**, create a token with **Object Read & Write** permissions.
4. Copy:
   - **Access Key ID** -> `AWS_ACCESS_KEY_ID`
   - **Secret Access Key** -> `AWS_SECRET_ACCESS_KEY`
   - **Endpoint** -> `AWS_ENDPOINT` (e.g., `https://<account_id>.r2.cloudflarestorage.com`)
5. In Bucket Settings -> **Public Access**, enable **R2.dev subdomain** or attach a custom domain (e.g., `media.yourdomain.com`). Set this as `AWS_URL`.

---

## 6. Connecting Flutter Mobile Devices

Update [`ApiConstants`](file:///Applications/XAMPP/xamppfiles/htdocs/laravel/couple_connect/frontend/lib/core/constants/api_constants.dart) with your Render backend URL and Pusher credentials:

```dart
class ApiConstants {
  // Replace with your Render public domain:
  static const String baseUrl = 'https://couple-connect-backend.onrender.com/api/v1';

  // Pusher WebSockets Credentials:
  static const String pusherAppKey = 'YOUR_PUSHER_APP_KEY';
  static const String pusherCluster = 'eu'; // match your Pusher cluster
}
```

### Building the Mobile APK / iOS App
```bash
# Build Android APK for physical devices
flutter build apk --release --dart-define=PUSHER_APP_KEY=YOUR_KEY --dart-define=PUSHER_APP_CLUSTER=eu

# Run on connected device
flutter run -d <device_id> --release
```

---

## 7. Verifying Real-Time WebSockets & Voice Notes

1. **User A records and sends voice note / document:**
   - Flutter uploads to `POST /api/v1/chat/voice` or `POST /api/v1/chat/documents`.
   - Laravel uploads directly to Cloudflare R2 bucket and persists metadata in MySQL.
   - Laravel broadcasts `NewMessageEvent` to Pusher cluster on private channel `private-couple.{space_id}`.
2. **User B on another network:**
   - Receives instant `message.new` WebSocket event via Pusher over WSS.
   - Chat UI updates seamlessly in real time.
   - Taps audio play button: audio streams directly from Cloudflare R2 CDN with byte-range streaming support.
