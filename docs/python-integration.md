# Python Integration

Call the `hermetic` CLI as a subprocess. The secret never enters your Python process.

## Authenticated API Request

```python
import subprocess, json

def hermetic_request(secret_name, url, method="GET", headers=None, body=None):
    args = ["hermetic", "request", "--secret", secret_name, "--url", url, "--method", method]
    if headers:
        for k, v in headers.items():
            args += ["--header", f"{k}: {v}"]
    if body:
        args += ["--body", body]
    result = subprocess.run(args, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip())
    return result.stdout

response = hermetic_request("github_token", "https://api.github.com/user")
```

## List Secrets

```python
result = subprocess.run(["hermetic", "list"], capture_output=True, text=True)
print(result.stdout)
```

## Why Not a Native SDK?

Hermetic uses SHA-256 binary attestation (HC-18). The daemon verifies that
the connecting process IS the hermetic binary. A Python native extension
runs inside `python3` — which fails attestation. The subprocess pattern
ensures the hermetic binary connects to the daemon, attests normally, and
handles credentials without them ever entering Python's address space.
