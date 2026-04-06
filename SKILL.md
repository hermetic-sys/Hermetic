# Hermetic — Credential Broker MCP Skill

## Description

Hermetic provides secure credential access for AI agents. The daemon holds API keys in an encrypted vault and makes authenticated calls on your behalf. You never receive credential values.

## Tools

### hermetic_authenticated_request

Make an authenticated HTTP request through the daemon. The credential is injected by the daemon — you never see it.

**Parameters:**
- `secret_name` (string, required) — Name of the stored secret
- `url` (string, required) — Target URL (HTTPS only, domain must match secret's allowed domains)
- `method` (string, optional) — HTTP method: GET, POST, PUT, DELETE, PATCH. Default: GET
- `body` (string, optional) — Request body (JSON string for POST/PUT)
- `headers` (object, optional) — Additional request headers (credential header is injected automatically)

**Returns:** `{ status: number, body: string, headers: object }`

**Example:**
```json
{
  "secret_name": "openai_key",
  "url": "https://api.openai.com/v1/chat/completions",
  "method": "POST",
  "body": "{\"model\":\"gpt-4\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}]}"
}
```

**Errors:**
- RequestDenied: secret not found, domain mismatch, or handle expired
- SSRF blocked: URL targets a private/internal IP range

---

### hermetic_env_spawn

Run a shell command with a credential injected as an environment variable. The credential exists only in the child process environment during execution.

**Parameters:**
- `secret_name` (string, required) — Name of the stored secret
- `env_var` (string, required) — Environment variable name for the credential
- `command` (string, required) — Command to execute

**Returns:** `{ exit_code: number }`

**Example:**
```json
{
  "secret_name": "github_pat",
  "env_var": "GITHUB_TOKEN",
  "command": "git push origin main"
}
```

**Notes:**
- Child process runs in isolated process group with sanitized environment
- Dangerous interpreters (sh, bash, python, node) are blocked by default
- Stdout/stderr are not captured — you only get the exit code
- Credential is wiped when the child process exits

---

### hermetic_list

List all stored secret names. Never returns credential values.

**Parameters:** none

**Returns:** `{ secrets: [{ name: string }] }`

---

### hermetic_list_meta

List secret metadata including auth scheme and allowed domains. Never returns credential values.

**Parameters:** none

**Returns:** `{ secrets: [{ name: string, auth_scheme: string, allowed_domains: [string] }] }`

**Use this to:** verify which domain a secret is bound to before making a request.

---

### hermetic_suggest_add

Suggest that the user add a new secret. Opens an interactive prompt where the user enters the credential value (hidden input). You never see the value.

**Parameters:**
- `name` (string, required) — Suggested secret name
- `template` (string, optional) — Service template (e.g., "openai", "stripe", "github")

**Returns:** `{ suggested: true }`

**Available templates:** openai, anthropic, stripe, github, aws, google_cloud, slack, twilio, sendgrid, datadog, and others. Run `hermetic templates` for the full list.

---

## Usage Patterns

### Making API Calls
```
1. hermetic_list_meta()                    → check if secret exists + verify domain
2. hermetic_authenticated_request(...)      → make the call
3. Parse response                          → use the data
```

### When a Secret Is Missing
```
1. hermetic_list()                         → confirm it's not stored
2. hermetic_suggest_add(name, template)     → guide user to add it
3. Wait for user to complete               → they type the key at a hidden prompt
4. hermetic_authenticated_request(...)      → now use it
```

### Git Operations with Credentials
```
hermetic_env_spawn(secret_name="github_pat", env_var="GITHUB_TOKEN", command="git push origin main")
```

### Infrastructure Commands
```
hermetic_env_spawn(secret_name="aws_key", env_var="AWS_ACCESS_KEY_ID", command="terraform plan")
```

## Constraints

- All URLs must be HTTPS (HTTP rejected)
- URL domain must match the secret's `allowed_domains` (checked per-request)
- Handles are single-use and expire in seconds — do not cache them
- The daemon verifies your binary identity on connection — non-hermetic processes are rejected
- Session tokens are bound to your process PID — tokens cannot be shared between processes
