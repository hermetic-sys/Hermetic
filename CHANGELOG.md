# Changelog

All notable changes to the Hermetic open-source core will be documented in this file.

This changelog covers the AGPL-licensed crates (hermetic-core, hermetic-transport, hermetic-sdk). Full binary release notes are published on [GitHub Releases](https://github.com/hermetic-sys/hermetic/releases).

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

**hermetic-sdk**
- Python SDK via PyO3 for credential resolution in Python scripts
- DaemonClient for vault operations from Python

---

The Hermetic Project · [hermeticsys.com](https://hermeticsys.com) · AGPL-3.0-or-later
