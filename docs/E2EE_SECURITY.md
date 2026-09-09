# COUPLE CONNECT – End-to-End Encryption (E2EE) Security Whitepaper

Couple Connect is engineered around zero-knowledge principles. Messages, voice notes, handwritten love letters, and shared sensitive documents are encrypted on device before ever touching the network.

---

## 1. Cryptographic Primitives

- **Asymmetric Key Agreement:** Curve25519 (ECDH) Key Exchange
- **Symmetric Encryption:** AES-256-GCM (Authenticated Encryption with Associated Data)
- **Key Derivation:** HKDF with SHA-256
- **Integrity Validation:** HMAC-SHA256 authentication tags (`mac`)
- **Nonce Generation:** 96-bit (12-byte) cryptographically secure CSPRNG initialization vectors (`iv`)

---

## 2. Key Exchange Workflow

```mermaid
sequenceDiagram
    autonumber
    participant Alice as Alice's Device
    participant Server as Laravel API
    participant Bob as Bob's Device

    Alice->>Alice: Generate Curve25519 Keypair (PrivA, PubA)
    Alice->>Server: Publish PubA (Device Identity Key)
    Bob->>Bob: Generate Curve25519 Keypair (PrivB, PubB)
    Bob->>Server: Publish PubB (Device Identity Key)

    Note over Alice,Bob: Connection Request Accepted -> Space Created
    Alice->>Server: Fetch Bob's PubB
    Bob->>Server: Fetch Alice's PubA

    Alice->>Alice: Compute ECDH(PrivA, PubB) -> Shared Secret Key (K_AB)
    Bob->>Bob: Compute ECDH(PrivB, PubA) -> Shared Secret Key (K_AB)

    Alice->>Alice: Encrypt("I love you", K_AB, IV) -> Ciphertext + Tag
    Alice->>Server: Transmit Ciphertext, IV, Tag
    Server->>Bob: Deliver Ciphertext, IV, Tag
    Bob->>Bob: Decrypt(Ciphertext, K_AB, IV, Tag) -> "I love you"
```

---

## 3. Threat Model & Protections

1. **Zero Knowledge Server Storage**:
   - The Laravel 12 backend and MySQL database store only high-entropy base64 ciphertexts. Even with complete database compromise, attackers cannot read any plaintext messages, letters, or voice transcripts.
2. **Replay Attack Resistance**:
   - Every message encapsulates a unique UUID and fresh 12-byte IV. Duplicate nonces trigger client-side rejection.
3. **Biometric & PIN Application Sandboxing**:
   - Private keys and session secrets are stored in iOS Keychain / Android Keystore / FlutterSecureStorage and wiped upon logout or repeated PIN failure.
