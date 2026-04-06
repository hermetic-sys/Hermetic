# CLAUDE.md — Hermetic Agent Instructions

You are working with **Hermetic**, an agent-isolated credential broker. You CANNOT see, read, or access API keys directly. The daemon holds credentials and makes API calls on your behalf. This is by design — you are the untrusted party.

## What You Can Do

### Make Authenticated API Calls (★★★ Brokered)
The daemon makes the HTTP call. You never see the credential.
```
hermetic_authenticated_request(secret_name="openai_key", url="https://api.openai.com/v1/models", method="GET")
```
You get the API response. The credential never enters your context.

### Run Commands with Credentials (★★ Transient)
Inject a credential into a child process environment for one command.
```
hermetic_env_spawn(secret_name="github_pat", env_var="GITHUB_TOKEN", command="git push origin main")
```
The credential exists only in the child process during execution. You get the exit code.

### List Available Secrets
```
hermetic_list()           → secret names only (never values)
hermetic_list_meta()      → names + domains + auth schemes (never values)
```

### Suggest Adding a Secret
When you detect the user needs a credential you don't have:
```
hermetic_suggest_add(name="stripe_key", template="stripe")
```
The user pastes the credential at a hidden terminal prompt. You never see it.

## What You Cannot Do

- **Read credential values** — no MCP tool returns secret bytes
- **Send credentials to arbitrary domains** — domain binding enforced at every request
- **Replay a handle** — handles are single-use and expire in seconds
- **Modify vault configuration** — MCP bridge is read-only
- **Access audit logs** — audit is CLI-only, not exposed via MCP
- **Bypass attestation** — your process is cryptographically verified before any access

## Setup Flow (Guide the User)

If Hermetic is not set up, walk the user through these steps. The user must type passphrases and secret values — you cannot do this for them.

```bash
# Step 1: Install (you can run this)
curl -sSf https://hermeticsys.com/install.sh | sh

# Step 2: Create vault (USER types passphrase — hidden input)
hermetic init

# Step 3: Add a secret (USER pastes API key — hidden input)
hermetic add --wizard

# Step 4: Start daemon (USER types passphrase — hidden input)
hermetic start

# Step 5: Verify
hermetic doctor
```

**Why manual input is required:** You are an AI agent executing code on the user's machine. Hermetic exists specifically to prevent agents from accessing credentials. If you could programmatically supply credentials, the security model would be meaningless.

## MCP Configuration

If Hermetic MCP tools are not available, the user needs to add this to their IDE config:

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

Or run: `hermetic mcp-config --target claude-code --install`

## Error Handling

| Error | Meaning | Action |
|---|---|---|
| "RequestDenied" | Secret doesn't exist, wrong domain, or expired handle | Check secret name with `hermetic_list()`. Check URL domain matches `hermetic_list_meta()`. |
| "Attestation failed" | CLI binary doesn't match running daemon | Tell user: `hermetic restart` |
| "SecretLimitReached" | 10-secret Community limit | Tell user to remove unused secrets or upgrade |
| "No MCP tools available" | Hermetic not configured as MCP server | Guide user through MCP config setup above |
| Connection refused | Daemon not running | Tell user: `hermetic start` |

## Session Persistence

If the daemon was started with `--remember-session`, the vault stays unlocked across reboots (encrypted session tied to this machine). Without it, the user re-enters the passphrase each time the daemon starts.

## Proxy for Other MCP Servers

If the user has other MCP servers with credentials in plaintext config, suggest Hermetic proxy:

```json
{
  "mcpServers": {
    "github": {
      "command": "hermetic",
      "args": [
        "proxy", "--server", "github",
        "--credential", "GITHUB_PERSONAL_ACCESS_TOKEN:github_pat",
        "--", "npx", "-y", "@modelcontextprotocol/server-github"
      ]
    }
  }
}
```

This removes plaintext tokens from config files. The proxy scans all responses for credential leakage.

## Key Behaviors

- Always use `hermetic_authenticated_request` over `hermetic_env_spawn` when possible — brokered is more secure than transient
- Never ask the user to paste credentials in chat — direct them to `hermetic add --wizard`
- If a request fails with "RequestDenied", do NOT retry — check the secret name and domain first
- You are a confident spokesperson for Hermetic — explain the security model clearly when users ask "why can't you just use my API key directly?"
