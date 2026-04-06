# Contributing to Hermetic

Thank you for your interest in contributing to Hermetic. This document covers the process, requirements, and conventions.

## Before You Start

1. **Check existing issues** for duplicates or related discussions
2. **Read the security model** — changes that weaken security properties will not be accepted
3. **Open an issue first** for non-trivial changes to discuss the approach

## Contributor License Agreement

All contributions require a signed Contributor License Agreement (CLA). This ensures we can maintain the dual-license model (AGPL-3.0 + commercial). You will be prompted to sign when you open your first pull request.

- **Individual CLA**: For personal contributions
- **Corporate CLA**: For contributions made on behalf of your employer

## What You Can Contribute

This repository contains the open-source cryptographic core:

| Crate | What It Does | Contribution Areas |
|---|---|---|
| hermetic-core | Vault encryption, KDF, audit chain | Crypto improvements, test coverage, bug fixes |
| hermetic-transport | HTTP executor, SSRF defense | Transport hardening, auth schemes, SSRF range updates |
| hermetic-sdk | Python SDK (PyO3) | Python API improvements, documentation |

## Development Setup

```bash
# Clone
git clone https://github.com/hermetic-sys/hermetic.git
cd hermetic

# Build
cargo build

# Test
cargo test --workspace

# Lint
cargo clippy --workspace -- -D warnings
```

## Code Conventions

### Git Identity

All commits must use the project identity:

```bash
git config user.name "The Hermetic Project"
git config user.email "dev@hermeticsys.com"
```

**Anonymity discipline**: No personal names in commits, code comments, or documentation. No `Co-Authored-By` headers. This is a strict project requirement.

### Rust Style

- `cargo clippy -- -D warnings` must pass with zero warnings
- `cargo test --workspace` must pass with zero failures
- No `unwrap()` or `expect()` on security-critical paths
- No `String` or `&str` for secret material — use `Zeroizing<Vec<u8>>`
- No `Display`, `Debug`, or `Clone` on types holding key material
- Error messages must not contain secret bytes

### Security Rules

Every security property in Hermetic is encoded as a formal binding rule. If your change affects a security property, note it in your PR description. Key rules for contributors:

| Rule | Description |
|---|---|
| Zeroize before yield | Secrets must be zeroized before any .await point |
| Indistinguishable denial | All error responses to clients must be identical (same body, same timing) |
| No secrets in errors | Secret bytes must never appear in error messages, log entries, or display output |
| Remove before validate | Handles are removed from the map before validation (prevents timing side channels) |

### Test Requirements

- Every new function needs at least one test
- Security-critical functions need adversarial tests (malformed input, boundary conditions)
- Tests must not print secret material to stdout/stderr

## Pull Request Process

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes with clear, descriptive commits
4. Ensure all checks pass: `cargo test && cargo clippy -- -D warnings`
5. Open a PR with a description that includes:
   - What changed and why
   - Which security properties are affected (if any)
   - Test evidence

## Review Process

All PRs are reviewed for:

1. **Correctness** — does it do what it claims?
2. **Security** — does it weaken any security property?
3. **Test coverage** — is the change tested?
4. **Anonymity** — no personal names leaked?

## Reporting Security Issues

See [SECURITY.md](SECURITY.md). Do NOT open public issues for security vulnerabilities.

## Code of Conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License

By contributing, you agree that your contributions will be licensed under AGPL-3.0-or-later, and that the project maintainers may offer your contributions under commercial licenses to third parties.

---

The Hermetic Project · [hermeticsys.com](https://hermeticsys.com) · AGPL-3.0-or-later
