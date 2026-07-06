# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | ✅ Active development |

## Reporting a Vulnerability

If you discover a security vulnerability, please **do not** open a public GitHub issue.

Instead, email: **turkelmert96@gmail.com** with:

- Description of the vulnerability
- Steps to reproduce
- Potential impact assessment
- Suggested fix (if any)

We aim to respond within **48 hours** and provide a remediation timeline within **7 days**.

## Security Practices

- All secrets managed via environment variables (`.env`, never committed).
- Production APIs enforce HTTPS/WSS with TLS.
- JWT tokens for authenticated B2B sessions (backend).
- Server-side input validation on all dispatch and tracking endpoints.
- Location data scoped to active delivery windows only.
