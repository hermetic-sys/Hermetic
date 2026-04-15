# Changelog

All notable changes to the Hermetic open-source core will be documented in this file.

This changelog covers the AGPL-licensed crates (hermetic-core, hermetic-transport). Full binary release notes are published on [GitHub Releases](https://github.com/hermetic-sys/hermetic/releases).

## [1.0.5] — 2026-04-15

### Added

**hermetic-core**
- Vault secret type detection for all credential types (static, OAuth2, AWS, JWT, SSH)

**hermetic-transport**
- Connection pool isolation — no connection reuse across credential-bearing requests
- Credential headers marked as sensitive to prevent logging exposure
- Custom header auth scheme (`header:<name>`) for APIs with non-standard headers

### Binary features (pre-built)
- SSH Agent protocol: Ed25519, RSA SHA-256/SHA-512, ECDSA P-256
- JWT signing: GitHub Apps, Azure AD (PS256), ES256, Custom provider
- Credential redaction on command output (stdout/stderr scanning)
- Auth scheme auto-resolution from secret metadata
- Session persistence interactive prompt
- New commands: ssh-keygen, ssh-allow, ssh-status, add --ssh-key, jwt-test, request --auth-scheme

## [1.0.0] — 2026-04-06

### Initial Release

**hermetic-core**
- AES-256-GCM per-secret encryption with per-secret key derivation via HKDF
- Argon2id memory-hard master key derivation (GPU/ASIC resistant)
- SQLCipher page-level database encryption
- HMAC-SHA256 tamper-evident audit chain
- Session persistence with machine-bound key derivation
- Secret metadata: name, auth scheme, allowed domains, tags, notes, expiration
- OAuth2 composite secret support (access token + refresh token lifecycle)
- Vault migration infrastructure (version detection, backup, integrity verification)

**hermetic-transport**
- HTTPS-only enforcement
- SSRF protection with DNS pinning and connect-by-IP architecture
- Redirect re-validation (DNS re-resolve per hop, credentials stripped)
- Forbidden request header stripping
- Response header allowlist
- Auth scheme injection (Bearer, Basic, X-Api-Key, Custom Header)
- Domain canonicalization pipeline (punycode, port strip, trailing dot, case normalization)
- Response size limits, connection pool isolation

---

The Hermetic Project · [hermeticsys.com](https://hermeticsys.com) · AGPL-3.0-or-later
