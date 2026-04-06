# Security Policy

## Reporting a Vulnerability

**Email**: [security@hermeticsys.com](mailto:security@hermeticsys.com)

**GPG Key**: [SIGNING_KEY.pub](SIGNING_KEY.pub)

We take every security report seriously. Please include:

1. Description of the vulnerability
2. Steps to reproduce
3. Impact assessment (what an attacker can achieve)
4. Your suggested fix (if any)

## Response Timeline

| Stage | Timeline |
|---|---|
| Acknowledgment | Within 48 hours |
| Initial assessment | Within 7 days |
| Fix development | Within 30 days for critical/high severity |
| Coordinated disclosure | 90 days from report |

## Scope

**In scope:**

- Credential extraction from daemon memory
- Handle protocol bypasses (replay, domain bypass, expiry bypass)
- Binary attestation bypasses (process spoofing, token theft)
- SSRF bypasses (private IP access, DNS rebinding)
- Transport vulnerabilities (header injection, redirect abuse)
- Vault encryption weaknesses
- MCP protocol information leakage

**Out of scope:**

- Root-level attacks (root can read any process memory)
- Kernel exploits (kernel compromise bypasses all process isolation)
- Physical access attacks (cold boot, hardware keylogger)
- Social engineering
- Denial of service against the local daemon
- Issues in dependencies (report upstream; notify us if security-critical)

## Known Limitations

The system documents known limitations publicly. These are not eligible for new reports unless you have a novel exploitation technique:

- Same-UID processes: Mitigated by binary attestation and per-message sender verification. A residual timing window of microseconds exists; the known exploit chain is blocked.
- `hermetic run`: Credentials exist in child process environment during execution. This is by design (★★ Transient tier). Credentials are wiped on process exit.
- `hermetic reveal`: Credentials are printed to terminal output. This is by design (★ Direct tier) and requires passphrase re-entry.

## Disclosure Policy

We follow coordinated disclosure. We will:

1. Confirm receipt of your report
2. Investigate and develop a fix
3. Credit you in the security advisory (unless you prefer anonymity)
4. Release the fix before public disclosure
5. Publish a security advisory with technical details

We will NOT:

- Take legal action against good-faith security researchers
- Share your report with third parties without your consent
- Disclose your identity without your permission

## Security Architecture

The cryptographic core in this repository (hermetic-core, hermetic-transport) is the foundation of the security model. The daemon and MCP bridge (distributed as compiled binary) implement attestation, the handle protocol, and dispatch logic.

Architecture documentation is available at [hermeticsys.com](https://hermeticsys.com).

---

The Hermetic Project · [hermeticsys.com](https://hermeticsys.com) · AGPL-3.0-or-later
