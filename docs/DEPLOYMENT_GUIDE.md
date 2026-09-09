# Couple Connect: Railway Production Deployment Guide

This guide walks you through deploying the **Couple Connect Laravel 12 Backend**, **Laravel Reverb WebSockets**, **Persistent S3/R2 Cloud Storage**, and connecting **Physical Android/iOS Flutter Devices**.

---

## 1. Architecture Overview

```
                      ┌─────────────────────────────────┐
                      │   Flutter Mobile/Web Clients    │
                      │  (Device A  ◄═══►  Device B)    │
                      └───────┬─────────────────▲───────┘
                              │ HTTPS           │ WSS (Port 443)
                              ▼                 │
     ┌──────────────────────────────────────────┴─────────────────────────┐
     │                      Railway.app Production                        │
     │                                                                    │
     │  ┌─────────────────────────┐         ┌──────────────────────────┐  │
     │  │  Laravel REST API       │         │  Laravel Reverb Daemon   │  │
     │  │  - Auth / E2EE / Chat   │────────►│  - Real-Time WebSockets  │  │
     │  │  - Document / Voice API │ Events  │  - Private Channels      │  │
     │  └───────────┬─────────────┘         └──────────────────────────┘  │
     │              │                                                     │
     │              │ MySQL TCP                                           │
     │              ▼                                                     │
     │  ┌─────────────────────────┐                                       │
     │  │  Railway MySQL Database │                                       │
     │  └─────────────────────────┘                                       │
     └──────────────────────┬─────────────────────────────────────────────┘
                            │
                            ▼
     ┌────────────────────────────────────────────────────────────────────┐
     │         Cloudflare R2 / AWS S3 Persistent Storage                  │
     │  - Encrypted Voice Notes (.m4a/.aac/.wav)                          │
     │  - Real PDF/DOCX/Images                                            │
     │  - High-Speed Worldwide Direct Streaming / CDN                     │
     └────────────────────────────────────────────────────────────────────┘
```

---

## 2. Deploying Backend to Railway.app

### Step A: Create Project on Railway
1. Open [railway.com](https://railway.com) and log in.
2. Click **+ New Project** -> **Deploy from GitHub repo**.
3. Select `couple_connect_app` (or your repository) and choose the `backend` folder as the Root Directory.

### Step B: Add MySQL Database Plugin
1. In your Railway project canvas, click **+ New** -> **Database** -> **Add MySQL**.
2. Railway will automatically create the database and inject variables (`MYSQLHOST`, `MYSQLPORT`, `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLDATABASE`).

### Step C: Configure Environment Variables
Add the following variables in the **Variables** tab of your Railway backend service:

```ini
APP_NAME="Couple Connect"
APP_ENV=production
APP_KEY=base64:... # Generate via `php artisan key:generate --show`
APP_DEBUG=false
APP_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}

# Database (Automatically mapped from MySQL plugin)
DB_CONNECTION=mysql
DB_HOST=${{MYSQLHOST}}
DB_PORT=${{MYSQLPORT}}
DB_DATABASE=${{MYSQLDATABASE}}
DB_USERNAME=${{MYSQLUSER}}
DB_PASSWORD=${{MYSQLPASSWORD}}

# Queue, Cache, Broadcast
BROADCAST_CONNECTION=reverb
FILESYSTEM_DISK=s3
QUEUE_CONNECTION=database
CACHE_STORE=database

# Reverb WebSockets
REVERB_APP_ID=couple_connect_app
REVERB_APP_KEY=couple_connect_key
REVERB_APP_SECRET=your_production_secure_secret_here
REVERB_HOST=${{RAILWAY_PUBLIC_DOMAIN}}
REVERB_PORT=443
REVERB_SCHEME=https
REVERB_SERVER_HOST=0.0.0.0
REVERB_SERVER_PORT=8080

# Cloud Media Storage (Cloudflare R2 or AWS S3)
AWS_ACCESS_KEY_ID=YOUR_R2_OR_S3_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=YOUR_R2_OR_S3_SECRET_KEY
AWS_DEFAULT_REGION=auto
AWS_BUCKET=couple-connect-media
AWS_USE_PATH_STYLE_ENDPOINT=true
AWS_ENDPOINT=https://<YOUR_ACCOUNT_ID>.r2.cloudflarestorage.com
AWS_URL=https://media.yourdomain.com
```

---

## 3. Persistent Media Storage Setup (Cloudflare R2)

Railway containers have ephemeral filesystems (files uploaded to local disk disappear on container redeploy). Cloudflare R2 provides zero-egress fee, persistent, lightning-fast media storage.

1. Create a Cloudflare account and go to **R2 Object Storage**.
2. Click **Create Bucket** -> Name it `couple-connect-media`.
3. In **R2 Manage API Tokens**, create a token with **Object Read & Write** permissions.
4. Copy the **Access Key ID**, **Secret Access Key**, and **Endpoint URL** into your Railway variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_ENDPOINT`).
5. (Optional) Connect a Custom Domain or enable R2 Public Access to allow instant audio/document streaming worldwide.

---

## 4. Connecting Flutter Mobile Devices (Android / iOS)

In the Flutter application, update [`ApiConstants`](file:///Applications/XAMPP/xamppfiles/htdocs/laravel/couple_connect/frontend/lib/core/constants/api_constants.dart) with your Railway URL:

```dart
class ApiConstants {
  // Replace with your Railway public domain:
  static const String baseUrl = 'https://couple-connect-production.up.railway.app/api/v1';
}
```

### Building the Mobile APK / iOS App
```bash
# Build Android APK for physical device
flutter build apk --release

# Run directly on plugged-in Android device
flutter run -d <device_id> --release
```

---

## 5. Verifying Real-Time WebSockets & Voice Streaming

1. **User A** records a voice message and presses send:
   - Voice note is recorded in AAC/M4A format.
   - Flutter uploads file to `POST /api/v1/chat/voice`.
   - Laravel uploads file to S3/R2 and saves record in MySQL.
   - Laravel triggers `NewMessageEvent` implementing `ShouldBroadcastNow` on `private-couple.{id}`.
2. **User B** (on physical device in another city/network):
   - Receives `message.new` event via WebSocket connection over WSS (Port 443).
   - Chat screen inserts message immediately without pulling or reloading.
   - Taps play: streams audio instantly from Cloudflare R2 / S3 CDN.
