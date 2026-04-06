# AGENTS.md — Hermetic Integration Guide for AI Agents

## What Is Hermetic

Hermetic is a credential broker running on the user's machine. It holds API keys in an encrypted vault and makes authenticated API calls on your behalf. You never receive credential values. This is intentional — you are an untrusted execution environment.

## Architecture

```
You (AI Agent)                    Hermetic Daemon
┌──────────────┐                 ┌──────────────────┐
│              │   opaque handle │                  │
│  Send request├────────────────►│  Injects real     │──── HTTPS ────► API
│              │                 │  credential       │
│  Receive     │◄────────────────┤                  │◄─── response ──┘
│  response    │   data only     │  Encrypted vault  │
│              │                 │  Audit log        │
└──────────────┘                 └──────────────────┘

Your memory: handle + response (never the credential)
Daemon memory: credential + domain rules + audit trail
```

## Available Operations

### 1. Authenticated Request (Preferred)
Make an API call through the daemon. Credential never leaves daemon memory.
```
Tool: hermetic_authenticated_request
Args: secret_name, url, method (GET/POST/PUT/DELETE), body (optional), headers (optional)
Returns: HTTP status code + response body
```

### 2. Environment Spawn
Run a CLI command with a credential injected as an environment variable.
```
Tool: hermetic_env_spawn
Args: secret_name, env_var, command
Returns: exit code (stdout/stderr not captured)
```

### 3. List Secrets
```
Tool: hermetic_list
Returns: array of secret names (never values)

Tool: hermetic_list_meta
Returns: array of {name, auth_scheme, allowed_domains} (never values)
```

### 4. Suggest Adding a Secret
When you detect a missing credential, prompt the user to add it:
```
Tool: hermetic_suggest_add
Args: name, template (optional)
Effect: user is guided through interactive secret entry
```

## Rules

1. **Never ask the user to paste credentials in your chat.** Direct them to `hermetic add --wizard` which uses hidden terminal input.
2. **Always prefer `authenticated_request` over `env_spawn`.** Brokered is more secure than transient.
3. **Check domain compatibility.** If a request returns "RequestDenied", the URL domain may not match the secret's allowed domains. Use `hermetic_list_meta` to check.
4. **Do not retry denied requests.** Fix the cause (wrong secret name, wrong domain) before retrying.
5. **You cannot read, extract, or reverse-engineer credentials.** The daemon verifies your binary identity, checks sender PID on every message, and binds session tokens to your process. Attempting to circumvent these protections will result in connection termination.

## Setup (If Not Configured)

If Hermetic tools are unavailable, the user needs to:

1. **Install:** `curl -sSf https://hermeticsys.com/install.sh | sh`
2. **Initialize:** `hermetic init` (user types passphrase)
3. **Add secrets:** `hermetic add --wizard` (user pastes API key)
4. **Start daemon:** `hermetic start` (user types passphrase)
5. **Configure MCP:** `hermetic mcp-config --install`

Steps 2-4 require user interaction at the terminal — you cannot supply passphrases or credentials programmatically.

## Common Errors

| Error | Cause | Resolution |
|---|---|---|
| RequestDenied | Secret not found or domain mismatch | `hermetic_list` to check names, `hermetic_list_meta` to check domains |
| Connection refused | Daemon not running | User runs `hermetic start` |
| Attestation failed | Binary version mismatch | User runs `hermetic restart` |
| SecretLimitReached | 10-secret limit (Community) | Remove unused secrets or upgrade |

## Why This Design

AI agents execute shell commands as the user. A prompt injection (in a GitHub issue, code comment, or API response) can instruct you to read `.env` files, access daemon sockets, or exfiltrate credentials. Hermetic prevents this by ensuring credentials never enter your process memory. Even if you are compromised, the credentials are safe.
