# Commercial License

## Open-Source Core

The cryptographic core of Hermetic (hermetic-core, hermetic-transport, hermetic-sdk) is licensed under the [GNU Affero General Public License v3.0 or later](LICENSE) (AGPL-3.0-or-later).

Under the AGPL, you may freely use, modify, and distribute these crates, provided that any network-facing service using modified versions makes the complete source code available to users.

## Commercial Licensing

For organizations that cannot comply with the AGPL's requirements (e.g., proprietary SaaS products, embedded systems, or internal tools where source disclosure is not feasible), commercial licenses are available.

**Contact**: [license@hermeticsys.com](mailto:license@hermeticsys.com)

## Pre-Built Binary

The Hermetic binary (including the daemon, MCP bridge, proxy, and CLI) is distributed as a compiled binary. It includes both AGPL-licensed components and proprietary components.

### Community Edition (Free)

- Complete security model — every security feature included
- 10 secrets, 1 environment
- Service templates for common APIs
- No registration, no telemetry, no cloud

### Pro Edition ($10/month or $99/year)

Everything in Community, plus:

- Unlimited secrets and environments
- Expanded service template library
- OAuth2 automatic token refresh
- Credential health monitoring
- TUI and web dashboards
- Token usage analytics
- Extended audit log retention
- Priority support

### Enterprise Edition (Custom Pricing)

Everything in Pro, plus:

- Custom integrations
- Dedicated support
- Volume licensing
- Custom audit retention

**Contact**: [license@hermeticsys.com](mailto:license@hermeticsys.com)

## Security Commitment

Security features are never gated behind a license tier. The encryption, attestation, handle protocol, SSRF protection, and all security mechanisms are identical across Community and Pro editions. The only differences are operational limits (secret count, environment count) and convenience features (dashboards, analytics, OAuth2 refresh).

## Dual-License FAQ

**Q: Can I use the AGPL crates in my open-source project?**
A: Yes, as long as your project is also AGPL-compatible and you provide source code to users.

**Q: Can I use the AGPL crates in my proprietary product?**
A: You need a commercial license. Contact license@hermeticsys.com.

**Q: Can I use the pre-built binary in my CI/CD pipeline?**
A: Yes. The binary is free for Community use. No license key required.

**Q: Does the AGPL apply to my code if I just use the binary?**
A: No. The AGPL applies to modifications of the AGPL-licensed source code. Using the binary as a tool does not create a derivative work.

**Q: What if my company prohibits AGPL dependencies?**
A: Contact us for a commercial license that replaces the AGPL terms with a standard proprietary license.

---

The Hermetic Project · [hermeticsys.com](https://hermeticsys.com) · AGPL-3.0-or-later
