<p align="center">
  <img src="assets/hermetic-logo.png" alt="Hermetic" width="120">
</p>

<h1 align="center">Hermetic</h1>

<p align="center">
  <strong>AI agents use your API keys without ever seeing them.</strong>
</p>

<p align="center">
  <a href="https://hermeticsys.com">Website</a> ·
  <a href="https://hermeticsys.com/install.sh">Install</a> ·
  <a href="https://github.com/hermetic-sys/hermetic/releases">Releases</a> ·
  <a href="SECURITY.md">Security</a> ·
  <a href="COMMERCIAL_LICENSE.md">Commercial License</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/language-Rust-orange" alt="Rust">
  <img src="https://img.shields.io/badge/license-AGPL--3.0-blue" alt="AGPL-3.0">
  <img src="https://img.shields.io/badge/platform-Linux%20x86__64-lightgrey" alt="Linux">
  <img src="https://img.shields.io/badge/telemetry-zero-brightgreen" alt="Zero telemetry">
</p>

---

Hermetic is a credential broker for AI agents. A local daemon holds your API keys in an encrypted vault, makes authenticated HTTPS calls on the agent's behalf, and returns only the response. The agent never sees, holds, or transmits the credential.

```
Agent: "Call the Stripe API with my key"
  ↓
Agent sends opaque handle to daemon
  ↓
Daemon injects real credential, makes HTTPS call
  ↓
Agent receives API response (no credential in sight)
```

Single binary. No dependencies. No cloud. No telemetry. Linux x86_64.

## Install

```bash
curl -sSf https://hermeticsys.com/install.sh | sh
```

Or download from [GitHub Releases](https://github.com/hermetic-sys/hermetic/releases).

## Quick Start

```bash
# 1. Initialize vault
hermetic init

# 2. Add a secret (auto-detects service from key prefix)
hermetic add --wizard

# 3. Start the daemon
hermetic start

# 4. Make an authenticated API call
hermetic request --secret openai_key \
  --url https://api.openai.com/v1/models

# 5. Check system health
hermetic doctor
```

## How It Works

Hermetic runs as a background daemon under your user account. When an AI agent (Claude Code, Cursor, VS Code Copilot) needs to call an API, it communicates with the daemon through the [Model Context Protocol](https://modelcontextprotocol.io) (MCP) over stdin/stdout.

The daemon:

1. Receives the request with a short-lived, single-use handle (not the credential)
2. Looks up the credential in the encrypted vault
3. Validates the target domain against the credential's allowed domains
4. Injects the credential into the HTTPS request
5. Makes the call with SSRF protection, DNS pinning, and redirect re-validation
6. Returns only the response — the credential never leaves daemon memory

The agent cannot read, copy, redirect, or exfiltrate the credential because it never enters the agent's address space.

## Security Model

| Layer | Protection |
|---|---|
| **Encryption** | AES-256-GCM per-secret encryption, Argon2id master key derivation, SQLCipher vault |
| **Process isolation** | Daemon in separate address space, memory-locked, dump-protected |
| **Binary attestation** | Connecting processes verified via cryptographic hash comparison |
| **Sender verification** | Per-message kernel-verified process identity on every request |
| **Handle protocol** | Short-lived, single-use, domain-bound credential tokens |
| **Transport** | HTTPS-only, SSRF blocking, DNS pinning, forbidden header stripping |
| **Spawn defense** | Dangerous binary blocklist, environment sanitization, process group isolation |

Open-source cryptographic core (AGPL-3.0). Fuzz tested. Adversarially reviewed. Memory-safe Rust.

## MCP Integration

Add to your IDE's MCP configuration:

```json
{
  "mcpServers": {
    "hermetic": {
      "command": "hermetic",
      "args": ["mcp"]
    }
  }
}
```

Or generate the config automatically:

```bash
hermetic mcp-config
```

## Three Security Tiers

| Tier | Command | Credential Exposure |
|---|---|---|
| ★★★ Brokered | `hermetic request` / MCP | Never — daemon makes the HTTP call |
| ★★ Transient | `hermetic run` | Milliseconds — in child process env only |
| ★ Direct | `hermetic reveal` | Terminal output — passphrase-gated |

## Community vs Pro

| | Community (Free) | Pro ($10/mo) |
|---|---|---|
| Security model | Complete — identical code path | Complete |
| Secrets | 10 | Unlimited |
| Environments | 1 | Unlimited |
| Binary attestation | Full | Full |
| MCP Proxy with leak scanning | Full | Full |
| OAuth2 auto-refresh | — | ✓ |
| Credential health monitoring | — | ✓ |
| TUI + Web dashboards | — | ✓ |

Security features are never gated behind a license tier.

## Verification

The system has been adversarially validated through independent red team campaigns, fuzz testing with zero crashes, mutation testing, and real-world attack simulations. The cryptographic core has zero breaches across all testing.

## Repository Structure

This repository contains the open-source cryptographic core:

```
crates/hermetic-core/       — Vault, encryption, KDF, audit chain
crates/hermetic-transport/  — HTTP executor, SSRF defense, DNS pinning
crates/hermetic-sdk/        — Python SDK (PyO3)
```

The daemon, MCP bridge, proxy, and CLI are distributed as a pre-built binary via `install.sh` and [GitHub Releases](https://github.com/hermetic-sys/hermetic/releases).

## Building from Source

```bash
git clone https://github.com/hermetic-sys/hermetic.git
cd hermetic
cargo build --release
```

This builds the open-source crates. The full binary (with daemon, MCP bridge, and proxy) is available from releases.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). All contributions require a signed CLA. The project follows strict anonymity discipline — no personal names in commits or code.

## License

The cryptographic core is licensed under [AGPL-3.0-or-later](LICENSE). Commercial licenses are available for proprietary use — see [COMMERCIAL_LICENSE.md](COMMERCIAL_LICENSE.md) or contact [license@hermeticsys.com](mailto:license@hermeticsys.com).

## Links

- **Website**: [hermeticsys.com](https://hermeticsys.com)
- **Security**: [security@hermeticsys.com](mailto:security@hermeticsys.com) — see [SECURITY.md](SECURITY.md)
- **License**: [license@hermeticsys.com](mailto:license@hermeticsys.com)
- **GPG Key**: [SIGNING_KEY.pub](SIGNING_KEY.pub)

---

<p align="center">
  <sub>The Hermetic Project · <a href="https://hermeticsys.com">hermeticsys.com</a> · AGPL-3.0-or-later</sub>
</p>
