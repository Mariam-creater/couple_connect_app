# COUPLE CONNECT – WebSocket Protocol & Real-Time Specifications

Couple Connect uses **Laravel Reverb / Pusher-compatible protocol** for bi-directional, sub-millisecond communication between couples.

---

## 1. Channel Topology

Every connected couple subscribes to their dedicated private presence channel:
- **Private Space Channel**: `private-couple-space.{couple_space_id}`
- **Multiplayer Battle Channel**: `presence-game-tournament.{session_code}`

---

## 2. Event Payload Contracts

### 1. `MessageSent`
Broadcasts when a partner sends an E2EE encrypted message.
- **Event Name:** `message.sent`
- **Channel:** `private-couple-space.{space_id}`
- **Payload:**
  ```json
  {
    "message_uuid": "550e8400-e29b-41d4-a716-446655440000",
    "sender_id": 2,
    "type": "text",
    "encrypted_payload": "Ct56jU+...",
    "iv": "v12...",
    "mac": "mac99...",
    "created_at": "2026-09-09T19:30:00Z"
  }
  ```

### 2. `TypingIndicator` (Client Whisper)
Broadcasts ephemeral typing signals without database round-trips.
- **Event Name:** `client-typing`
- **Payload:**
  ```json
  {
    "user_id": 2,
    "is_typing": true
  }
  ```

### 3. `ReactionAdded`
Broadcasts live emoji reactions.
- **Event Name:** `message.reaction`
- **Payload:**
  ```json
  {
    "message_id": 142,
    "user_id": 3,
    "reaction": "❤️"
  }
  ```

### 4. `GameTurnExecuted`
Transfers chess moves, dice rolls, or trivia answers immediately to partner device.
- **Event Name:** `game.move`
- **Payload:**
  ```json
  {
    "session_code": "uuid...",
    "user_id": 2,
    "move_number": 8,
    "move_data": {
      "fen": "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2"
    }
  }
  ```

### 5. `PartnerPresenceChanged`
Signals when a partner opens the app or goes away.
- **Event Name:** `partner.presence`
- **Payload:**
  ```json
  {
    "user_id": 3,
    "status": "online",
    "last_seen_at": "2026-09-09T19:35:00Z"
  }
  ```
