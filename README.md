# 💍 COUPLE CONNECT – Private Couple Social Platform

> A private social operating system crafted strictly for two people in a relationship. Built with **Flutter 3.44+**, **Laravel 12 REST API**, **MySQL**, **WebSockets**, **Google Gemini AI**, and **End-to-End Encryption (AES-256-GCM + Curve25519)**.

---

## 🌟 Core Features

- **Couple Connection Lifecycle**: Single ➡️ Search by Username / Couple ID (e.g. `CP-ALEX-77`) ➡️ Send/Accept Request ➡️ Auto-created Private Couple Space.
- **Real-Time Live Chat**: Text, emoji reactions, voice note waveforms, pinned messages, read receipts, and client-side E2EE encryption.
- **Love Calendar**: Anniversary countdowns, date nights, travel milestones, recurring reminders, and color tags.
- **Love Memories Vault**: Encrypted letters, photo gallery, voice memos, and categorized albums.
- **Couple Games**:
  - *1-on-1 Games*: Truth or Dare, Speed Chess, Couple Ludo, Love Trivia, Would You Rather.
  - *Couple vs Couple Battles (2v2)*: Team matchmaking, seasonal leaderboards, and Elo ratings.
- **Shared Vision Board**: Life goals (Dream House, Travel, Wedding, Savings) with checkable milestones and progress tracking.
- **Couple Streak & Badges**: 7-day spark, 30-day flame, 365-day golden heart, daily check-in prompts, and annual summaries.
- **AI Relationship Assistant**: Google Gemini-powered tone scanner, conflict de-escalation tips, romantic letter/apology generator, and custom date itineraries.
- **Administration & Security**: Biometric login, PIN lock, rate limiting, and admin metrics dashboard.

---

## 🏗️ Project Architecture

```
couple_connect/
├── backend/                  # Laravel 12 REST API & WebSocket Engine
│   ├── app/                  # Models, Controllers, Services, Repositories
│   ├── database/             # Migrations, Seeders (Demo couples & content)
│   ├── routes/               # Versioned REST endpoints (api.php)
│   ├── tests/                # Feature and Unit test suites
│   ├── Dockerfile            # Production PHP 8.2 container
│   └── docker-compose.yml    # Nginx, PHP-FPM, MySQL 8, Redis
│
├── frontend/                 # Flutter Cross-Platform Client (iOS, Android, Web)
│   ├── lib/                  # Core Theme (M3 Glassmorphic), Crypto, Providers, Screens
│   ├── test/                 # Smoke & Widget tests
│   └── pubspec.yaml          # Dependencies
│
└── docs/                     # Comprehensive Documentation
    ├── API_SPECIFICATION.md  # REST API endpoints & schemas
    ├── WEBSOCKET_EVENTS.md   # Real-time WebSocket contracts
    ├── E2EE_SECURITY.md      # Cryptographic security protocol
    └── DEPLOYMENT_GUIDE.md   # Production deployment guide
```

---

## 🚀 Quick Start

### 1. Launch Laravel 12 Backend
```bash
cd backend
composer install
php artisan migrate --force
php artisan db:seed --class=CoupleConnectSeeder
php artisan serve --port=8000
```

### 2. Launch Flutter Client
```bash
cd frontend
flutter pub get
flutter run -d chrome  # or ios / android
```

### 3. Demo Credentials
- **Partner 1 (Alexander)**: `alex@coupleconnect.app` / `Password123!` (Couple ID: `CP-ALEX-77`)
- **Partner 2 (Sophia)**: `sophia@coupleconnect.app` / `Password123!` (Couple ID: `CP-SOPH-88`)
- **Administrator**: `admin@coupleconnect.app` / `AdminSecret123!`
