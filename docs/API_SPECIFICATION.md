# COUPLE CONNECT – REST API Specification v1

Base URL: `http://localhost:8000/api/v1` (Production: `https://api.coupleconnect.app/api/v1`)
Authentication: `Authorization: Bearer <Sanctum_Token>`

---

## 1. Authentication & Security

### `POST /auth/register`
Creates a single account and automatically assigns a unique Couple ID (e.g. `CP-8842-AB`).
- **Request Body:**
  ```json
  {
    "name": "Alexander Vance",
    "username": "alex",
    "email": "alex@coupleconnect.app",
    "password": "Password123!",
    "public_key": "Curve25519_Public_Key_Hex"
  }
  ```
- **Response (201 Created):**
  ```json
  {
    "status": "success",
    "data": {
      "user": {
        "id": 2,
        "name": "Alexander Vance",
        "username": "alex",
        "email": "alex@coupleconnect.app",
        "couple_id": "CP-ALEX-77",
        "relationship_status": "single"
      },
      "token": "1|sanctum_plain_text_token..."
    }
  }
  ```

### `POST /auth/login`
- **Request Body:**
  ```json
  {
    "login": "alex@coupleconnect.app",
    "password": "Password123!",
    "fcm_token": "fcm_device_token_optional"
  }
  ```
- **Response (200 OK):**
  ```json
  {
    "status": "success",
    "data": {
      "user": { ... },
      "partner": { ... },
      "token": "2|sanctum_token..."
    }
  }
  ```

### `GET /auth/me`
Fetches authenticated user profile, linked partner details, active couple space, streak counters, and team Elo rank.

---

## 2. Couple Connection

### `GET /couple/search?query=sophia`
Searches single users by exact username or unique Couple ID.

### `POST /couple/request`
- **Request Body:** `{"receiver_id": 3}`
- **Behavior:** Ensures sender is single and target is single. Places user in `pending` status.

### `GET /couple/requests`
Returns list of incoming and outgoing pending couple connection invites.

### `POST /couple/request/{id}/accept`
Accepts invitation and atomically generates the isolated `couple_spaces` record, initializes a 1-day starter streak, and registers the couple team for tournament matchmaking.

---

## 3. Real-Time Chat & E2EE Messages

### `GET /chat/messages?per_page=40`
Returns paginated message models with client-side encrypted payloads, initialization vectors (`iv`), MAC tags, reactions, and attachments.

### `POST /chat/messages`
- **Request Body:**
  ```json
  {
    "type": "text",
    "encrypted_payload": "AQIDBAUGBwgJCgsMDQ4PEBESExQ...",
    "iv": "dGhpcyBpcyBhIDEyLWJ5dGUgaXY=",
    "mac": "aGFzaF9tYWM=",
    "reply_to_message_id": null
  }
  ```

### `POST /chat/messages/{id}/react`
- **Request Body:** `{"reaction": "❤️"}`

### `POST /chat/messages/read`
Marks all partner incoming messages as read, triggering delivery/read tick sync.

---

## 4. Love Calendar & Countdowns

### `GET /calendar/events?category=anniversary`
Returns upcoming events and active countdown timers.

### `POST /calendar/events`
- **Request Body:**
  ```json
  {
    "title": "Kyoto Vacation",
    "category": "travel",
    "color_hex": "#9C27B0",
    "start_time": "2026-10-07T08:00:00Z",
    "is_countdown": true,
    "location": "Kyoto, Japan"
  }
  ```

---

## 5. Love Memories Vault

### `GET /memories?category=photo&album_name=Greece Summer`
Returns encrypted memories and vaulted photos.

### `POST /memories`
Uploads encrypted body letters or media attachments into S3/vault storage.

---

## 6. Couple Games & Tournaments

### `POST /games/start`
- **Request Body:**
  ```json
  {
    "game_type": "chess",
    "mode": "1v1_couple"
  }
  ```

### `POST /games/sessions/{sessionCode}/move`
Submits turn data (FEN/chess move, dice roll, answer choice) and switches active turn. In multiplayer mode, recalculates Elo rating upon match completion.

---

## 7. Shared Vision Board

### `GET /vision-boards`
Returns dream boards (Dream House, Travel, Wedding, Savings, Business) with milestone checklists.

### `POST /vision-boards/{boardId}/items`
Adds milestone task or sticky note.

### `POST /vision-boards/items/{itemId}/toggle`
Toggles milestone completion and records streak activity log.

---

## 8. AI Relationship Assistant

### `POST /ai/analyze-tone`
- **Request Body:**
  ```json
  {
    "message_text": "I feel like you didn't pay attention to me earlier today."
  }
  ```
- **Response:**
  ```json
  {
    "status": "success",
    "data": {
      "tone": "Vulnerable",
      "respect_score": 85,
      "emotional_balance": "Balanced",
      "positive_signals": ["Honest expression of feelings"],
      "conflict_prevention_tips": ["Express affection before stating need for quality time"],
      "alternative_drafts": ["I really cherish our time together and missed having your full presence earlier today."]
    }
  }
  ```
