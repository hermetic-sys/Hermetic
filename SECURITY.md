# Security Policy

## Reporting a Vulnerability

**Do NOT open a public GitHub issue for security vulnerabilities.**

Email **[security@hermeticsys.com](mailto:security@hermeticsys.com)** with:

- Description of the vulnerability
- Steps to reproduce
- Affected component(s): `hermetic`, `hermetic-core`, `hermetic-daemon`, `hermetic-mcp`, `hermetic-transport`, `hermetic-cli`, `hermetic-sdk`
- Impact assessment (what an attacker could achieve)
- Any suggested fix (optional, always appreciated)

You will receive a response — not an auto-reply.

## Safe Harbor

Hermetic considers security research conducted in good faith to be authorized and will not pursue legal action against researchers who:

- Act in good faith to avoid privacy violations, data destruction, and service disruption
- Report vulnerabilities through this channel before public disclosure
- Allow reasonable time for a fix before any public discussion
- Do not exploit vulnerabilities beyond what is necessary to demonstrate the issue

If you are uncertain whether your research qualifies, contact us first. We would rather hear about a potential issue than have a researcher stay silent out of concern.

## Response Timeline

| Severity | Acknowledgment | Initial Assessment | Fix Target | Disclosure |
|----------|---------------|-------------------|------------|------------|
| Critical | 24 hours | 48 hours | 48 hours | With fix release |
| High | 48 hours | 7 days | 7 days | With fix release |
| Medium | 48 hours | 7 days | 30 days | 90 days or fix release |
| Low | 72 hours | 14 days | Next release | 90 days or fix release |

Public disclosure follows the **90-day** standard: 90 days after the initial report, or when the fix is released, whichever comes first. If we need an extension, we will explain why and agree on a revised date with the reporter.

## What Qualifies

Any issue that undermines Hermetic's security properties is in scope:

- **Agent isolation bypass** — agent process obtains raw secret bytes through any path (MCP responses, error messages, logs, panic payloads, Debug/Display output, or side channels)
- **Python SDK escape-hatch bypass** — circumventing any of the 16 blocked introspection paths (`str`, `repr`, `pickle`, `json`, `format`, `getattr`, `hash`, `eq`, `len`, `iter`, `bytes`, `int`, `float`, `bool`, `dir`, `__reduce__`) to extract secret material into the Python runtime
- **Handle protocol violations** — replay, cross-UID redemption, TTL bypass, version fingerprint circumvention (HC-10), or any path to redeem a handle more than once (CC-1)
- **SSRF protection bypass** — reaching any of the 22 blocked private/reserved IP ranges, DNS rebinding past the resolve-then-validate-then-pin chain, or redirect re-validation bypass
- **Cryptographic weaknesses** — flaws in the Argon2id KDF parameterization, HKDF derivation chain, AES-256-GCM per-secret encryption, SQLCipher page-level encryption, or HMAC-SHA256 audit chain
- **Memory safety violations** — secret material in unprotected memory (swap, core dumps, /proc), failure of `Zeroizing<Vec<u8>>` wrappers, or mlockall bypass
- **Header injection** — bypassing the 12 forbidden headers (HC-7) or the User-Agent injection requirement (HC-12)
- **Shell injection** — bypassing the 26-binary blocklist (HC-8) in env_spawn, or escaping the command execution boundary
- **Wire protocol vulnerabilities** — framing bypass, unbounded allocation, frame deadline circumvention (HC-9)
- **Authentication bypass** — SO_PEERCRED circumvention or daemon socket access control failures
- **Audit log tampering** — modifying, deleting, or replaying audit entries without detection by the HMAC-SHA256 chain verification
- **Domain binding bypass** — making an authenticated request to a domain not in the secret's `allowed_domains` list (MCP-7)

## What Does Not Qualify

- Bugs in development tooling, CI configuration, or documentation
- Denial of service via resource exhaustion on localhost (the daemon is local-only in V1 and single-threaded by design — SM-4)
- Social engineering attacks
- Vulnerabilities in dependencies that do not affect Hermetic's usage of them (we run `cargo audit` and `cargo deny` in CI — please report upstream)
- Issues requiring root or elevated privileges (root bypasses all userspace protections; this is out of scope for any userspace application)
- Same-UID process access to the daemon socket — this is a known V1 scoping decision (V1-LIM-1), not a vulnerability. SO_PEERCRED verifies UID only. Any same-UID process can connect. We document this prominently because it is the most important limitation to understand.
- Theoretical attacks requiring hardware memory forensics, CPU cache inspection, or VM snapshot analysis (V1 does not use hardware enclaves)

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x | ✅ Active security support |
| < 1.0 | ❌ No support |

## How Security Fixes Are Tracked

Hermetic uses a constitutional governance model. Every security fix is formalized as a **constitutional amendment** (HC-*, MCP-*, CC-*, SM-*, etc.) with binding language, enforcement mechanism, and code-level verification. The full amendment registry is published in [`docs/`](docs/).

Vulnerabilities that have been reported, fixed, and disclosed are tracked publicly:

| ID | Issue | Status |
|----|-------|--------|
| HC-7 | Header injection in agent-supplied custom headers | Fixed, amendment ratified |
| HC-8 | Shell bypass via interpreter invocation in env_spawn | Fixed, amendment ratified |
| HC-10 | Ghost handle attack via secret rotation without version binding | Fixed, amendment ratified |
| HC-13 | Credential leakage via query parameter authentication | Auth scheme removed, amendment ratified |
| F-10 | Residual template reference after removal | Fixed |

We fix vulnerabilities — we do not hide them.

## Recognition

Security researchers who report valid vulnerabilities will be credited in the fix commit message, the corresponding constitutional amendment, and the project's security advisories — unless they prefer anonymity.

## Encryption

PGP key not yet published. Email [security@hermeticsys.com](mailto:security@hermeticsys.com) in plaintext for now. PGP key will be published when the project reaches v1.2.0.

If your report contains sensitive material (proof-of-concept exploits, credentials, or customer data), note this in your email subject line and we will establish an encrypted channel before you share details.

---

<p align="center">
<a href="https://hermeticsys.com">hermeticsys.com</a> · AGPL-3.0-or-later
</p>
