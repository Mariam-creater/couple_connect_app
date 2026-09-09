# 💍 COUPLE CONNECT – Complete System Architecture & Final Deliverables

> **Couple Connect** is an ultra-private, cross-platform couple social operating system crafted strictly for 1-to-1 relationships. Built with **Flutter 3.44+**, **Laravel 12 REST API**, **MySQL 8**, **WebSockets**, **Google Gemini AI**, and **Client-Side End-to-End Encryption (Curve25519 + AES-256-GCM)**.

---

## 📋 Comprehensive Deliverables Matrix

| Component | Technology | Key Capabilities & Deliverables |
| :--- | :--- | :--- |
| **📱 Flutter Android App** | Flutter 3.44+ / Kotlin | Material 3 Glassmorphism UI, Biometric Fingerprint/Face unlock, Local notifications, Android Adaptive Icons, Senders & Receivers E2EE encryption |
| **🍏 Flutter iOS App** | Flutter 3.44+ / Swift | Cupertino adaptive widgets, Face ID biometric lock, APNs Push Notifications, Native smooth animations, Safe Area & Dynamic Island support |
| **🌐 Responsive Web App** | Flutter Web (Wasm/CanvasKit) | Responsive Sidebar `NavigationRail`, Full-screen multi-column chat & memories grid, Keyboard shortcuts, Responsive across mobile, tablet, and widescreen |
| **🚀 Laravel 12 Backend** | PHP 8.2+ / Laravel 12 | RESTful API controllers, Sanctum token authentication, Rate limiting, Event broadcasting, E2EE key exchange registry |
| **🗄️ MySQL Database** | MySQL 8.0+ / SQLite | Normalized relational schema with strict couple isolation, automated index optimization, cascade deletes on couple separation |
| **📄 REST API Documentation** | OpenAPI 3.0 / Markdown | Complete endpoint specifications with sample requests, responses, status codes, and error schemas (`docs/API_SPECIFICATION.md`) |
| **🛡️ Admin Dashboard** | Laravel API + Flutter Admin UI | Platform metrics, telemetry, active couples counter, user directory, moderation queues, and storage tracker |
| **⚡ WebSocket Integration** | Laravel Reverb / Pusher | Instant messaging, typing indicators, online/offline presence, read receipts, and live multiplayer turn sync |
| **🤖 AI Integration** | Google Gemini AI | Romantic letter generator, relationship tone scanner, conflict de-escalation tips, and personalized date itinerary planner |
| **🔐 End-to-End Encryption** | Curve25519 + AES-256-GCM | Zero-knowledge server architecture where only the couple holds private decryption keys; server stores only encrypted payloads |
| **🔔 Push Notifications** | Firebase Cloud Messaging (FCM) | Background alerts for incoming messages, anniversary countdown milestones, partner game invites, and daily streak reminders |
| **🚢 Production Deployment** | Docker & Compose / Nginx / Redis | Automated multi-stage Docker builds, Nginx reverse proxy configuration, systemd daemons, and Let's Encrypt SSL instructions |

---

## 🏛️ System Architecture Diagram

```
 +-------------------------------------------------------------------------+
 |                      COUPLE CONNECT CLIENT APPS                         |
 |  [ Flutter Android ]      [ Flutter iOS ]      [ Responsive Flutter Web]|
 +--------------------+-------------+--------------------+-----------------+
                      |             |                    |
        HTTPS REST API|             |E2EE Keys           |WebSockets
       (Sanctum Token)|             |(Curve25519)        |(Reverb/Pusher)
                      v             v                    v
 +-------------------------------------------------------------------------+
 |                    LARAVEL 12 PRODUCTION BACKEND                        |
 |  ├── Auth & Profile Module          ├── E2EE Message Router             |
 |  ├── Couple Connection Lifecycle    ├── Love Calendar & Memories Vault  |
 |  ├── Couple Gaming & Tournaments    ├── Shared Vision Board             |
 |  ├── Streak Engine & Gamification   ├── Gemini AI Assistant Service     |
 |  └── Admin Telemetry & Moderation   └── Queue Worker & Push Dispatcher  |
 +--------------------+-------------+--------------------+-----------------+
                      |             |                    |
                      v             v                    v
           +------------------+  +------------------+  +------------------+
           | MySQL 8 Database |  | Redis 7 & Reverb |  | Google Gemini AI |
           | (Strict 1-to-1)  |  | (Cache/Sockets)  |  | (v1beta API)     |
           +------------------+  +------------------+  +------------------+
```

---

## 🗄️ Database Entity-Relationship Model (MySQL)

1. **`users`**: User identity, unique Couple ID (`CP-XXXX-YY`), relationship status (`single`, `pending`, `connected`), Curve25519 public key, and privacy flags.
2. **`couple_spaces`**: The isolated 1-to-1 container for two partners (`user_one_id`, `user_two_id`, `theme_preset`, `anniversary_date`, `connected_at`).
3. **`couple_requests`**: Connection handshake records (`sender_id`, `receiver_id`, `status: pending|accepted|rejected|cancelled`).
4. **`messages`**: E2EE encrypted chat messages (`encrypted_payload`, `iv`, `mac`, `type: text|photo|video|voice|doc`, `is_pinned`, `status`).
5. **`calendar_events`**: Shared dates, anniversaries, countdowns, and recurrence rules.
6. **`memories`**: Love letters, photo albums, voice notes, encrypted vaults, and file size tracking.
7. **`game_sessions`**: 1v1 and 2v2 multiplayer matches, active board states (FEN, Ludo coordinates, quiz answers), scores, and Elo ratings.
8. **`vision_boards` & `vision_items`**: Shared couple goals (Dream House, Wedding, Savings, Travel) with milestone checklists and sticky notes.
9. **`couple_streaks` & `streak_activity_logs`**: Continuous relationship activity tracking, daily check-ins, XP, levels, and badge unlocks.
10. **`report_and_blocks`**: Safety, abuse reporting, and moderation tracking.

---

## 🔐 End-to-End Cryptographic Security Protocol

- **Key Generation**: Upon account creation, the client generates a Curve25519 public/private keypair. The private key never leaves the device and is securely stored in Android EncryptedSharedPreferences / iOS Keychain.
- **Shared Secret Derivation**: When a couple space is created, the two devices compute a shared secret via Elliptic Curve Diffie-Hellman (ECDH).
- **Message Encryption**: Each message is encrypted client-side using **AES-256-GCM** with a cryptographically secure 12-byte initialization vector (`iv`) and 16-byte authentication tag (`mac`).
- **Zero-Knowledge Principle**: The Laravel backend and database only see encrypted base64 ciphertexts and cannot read any private chat content or private memory letters.

---

## 🚀 Quick Run & Test Commands

### 1. Run Automated Test Suites
```bash
# Backend Laravel Unit & Feature Tests
cd backend
php artisan test

# Frontend Flutter Widget & Unit Tests
cd frontend
flutter test
```

### 2. Launch Local Development
```bash
# Backend (Port 8000)
cd backend && php artisan serve

# Frontend (Chrome Web / Mobile)
cd frontend && flutter run -d chrome
```

### 3. Production Docker Deployment
```bash
cd backend
docker-compose up -d --build
```
