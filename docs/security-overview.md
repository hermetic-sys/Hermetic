# Security Overview

Hermetic uses agent-isolated credential brokering: the daemon holds credentials in memory-locked pages and makes API calls on behalf of AI agents. Agents receive HTTP responses but never observe the credentials used to obtain them.

## Nine Defense Layers

| Layer | Description |
|:------|:------------|
| **Encrypted vault** | AES-256-GCM per-secret, Argon2id master key, SQLCipher database encryption |
| **Process isolation** | Daemon in separate address space, memory locked in RAM, dump-protected, core dumps disabled |
| **Binary attestation** | Cryptographic hash of connecting binary verified on every connection. Unrecognized binaries are rejected before any credential access. |
| **Sender verification** | Kernel verifies sender identity on every message — blocks file descriptor sharing attacks |
| **Process-bound tokens** | Session tokens tied to originating process — stolen tokens are rejected from a different process |
| **Handle protocol** | Short-lived, single-use, domain-bound credential tokens |
| **Transport** | HTTPS-only, SSRF blocking, DNS pinning, redirect re-validation, forbidden header stripping |
| **Spawn defense** | Dangerous interpreter blocklist, environment sanitization, process group isolation |
| **Debugger detection** | Aborts if process is being traced at startup |

## Cryptographic Foundation

The open-source `hermetic-core` crate implements:

- **AES-256-GCM** authenticated encryption (per-secret)
- **Argon2id** key derivation (memory-hard)
- **HKDF-SHA256** key hierarchy
- **SQLCipher** encrypted vault
- **HMAC-SHA256** audit chain

## Transport Security

The open-source `hermetic-transport` crate implements:

- SSRF defense with DNS pinning
- Forbidden header stripping
- Redirect re-validation per hop

## Memory Protection

- Memory locking (secrets never swapped to disk)
- Core dump prevention
- Zeroizing wrappers (secrets zeroed after use)

## Testing

Hermetic is continuously fuzz tested with libFuzzer and AddressSanitizer, and has undergone multiple adversarial review campaigns during development. Vulnerabilities discovered during development were fixed and the defenses verified. Full evidence is published in the [whitepaper](https://hermeticsys.com/whitepaper).

## Vulnerability Disclosure

See [SECURITY.md](../SECURITY.md).
