# Contributing to LOOP

Thank you for your interest in contributing. This project follows enterprise-grade development practices.

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code |
| `feat/*` | New features |
| `fix/*` | Bug fixes |
| `docs/*` | Documentation only |
| `refactor/*` | Code restructuring |

## Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add autonomous courier assignment screen
fix: resolve map marker rendering on web
docs: update architecture diagram in README
refactor: extract order state into Riverpod provider
test: add widget tests for login flow
chore: bump flutter_map to 8.3.0
```

## Pull Request Process

1. Fork the repository and create a feature branch from `main`.
2. Write clear, scoped commits following the convention above.
3. Ensure `flutter analyze` passes with no errors.
4. Update README if you change architecture, env vars, or setup steps.
5. Open a PR with:
   - **What** changed
   - **Why** it was needed
   - **How** to test it
6. Request review; address feedback before merge.

## Code Style

- Follow [Effective Dart](https://dart.dev/effective-dart) guidelines.
- Use `flutter_lints` — no analyzer warnings in PRs.
- Keep widgets small and composable; business logic in providers.

## Security

- Never commit `.env`, API keys, or credentials.
- Report vulnerabilities via [SECURITY.md](./SECURITY.md) — do not open public issues.
