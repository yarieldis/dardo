# CLAUDE.md - Dardo API

This file provides guidance to Claude Code when working with the **Dardo** REST API repository.

## Shell Preferences

- **Always use PowerShell** for shell commands. Never use Bash — this is a Windows environment and Bash does not have access to Dart or other Windows-installed tools.
- `ls` → `Get-ChildItem`, `grep` → `Select-String`, `cat` → `Get-Content`
- Path separator: `\`, env vars: `$env:VAR`
- **Do NOT prefix commands with `Set-Location`** — the working directory is already set to the repo root.

## Repository Overview

**Purpose**: REST API backend built with Dart Frog.

**Status**: Active development

**Technology Stack**:
- Dart SDK ^3.11.0
- Dart Frog ^1.1.0

## Project Structure

```
root/
├── lib/auth/              # Auth helpers (JWT, claims, user store)
│   ├── claims.dart        # AuthClaims model
│   ├── jwt.dart           # JWT sign/verify
│   └── users.dart         # In-memory user store
├── routes/
│   ├── _middleware.dart   # Global auth middleware (Bearer token)
│   ├── auth/
│   │   └── login.dart     # POST /auth/login
│   └── index.dart         # GET / (protected)
├── test/routes/           # Route tests
├── pubspec.yaml           # Dependencies
├── analysis_options.yaml  # Lint rules (dart_frog_lint)
└── .dart_frog/            # Dart Frog internals (generated)
```

## Quick Start

### Development Server
```powershell
dart_frog dev
```
Starts on http://localhost:8080 with hot reload enabled.

### Tests
```powershell
dart test                           # Run all tests
dart test test/routes/index_test.dart  # Run specific test file
```

### Build
```powershell
dart_frog build   # Production build output to build/
```

## Architecture

### Authentication

Bearer token (JWT) authentication is enforced globally via `routes/_middleware.dart`.

- **Secret**: set via `JWT_SECRET` env var (falls back to `dev-secret` in development).
- **Login**: `POST /auth/login` with `{"username": "...", "password": "..."}` returns `{"token": "..."}`.
- **Protected routes**: all routes except `/auth/*` require `Authorization: Bearer <token>`.
- **User identity**: after auth, route handlers access the user via `context.read<AuthClaims>()`.
- **User store**: `lib/auth/users.dart` — currently in-memory; swap `UserStore` for a database-backed implementation.

### File-based routing
- `routes/index.dart` → `GET /`
- `routes/users.dart` → `GET /users`
- `routes/users/[id].dart` → `GET /users/:id`
- Each route file exports an `onRequest(RequestContext)` function.

### Middleware
- Use `middleware` in a route file to apply middleware to that route.
- Global middleware goes in `routes/_middleware.dart`.

### Dependency injection
- Use `RequestContext` to pass dependencies via `context.read<T>()` / `context.use<T>()`.

## Version Control Guidelines

- **NEVER** commit changes without user approval. Ask systematically for approval before committing.
- Commit message prefixes:
  - `feat:` New feature
  - `fix:` Bug fix
  - `docs:` Documentation
  - `style:` Formatting
  - `refactor:` Code restructuring
  - `test:` Adding tests
  - `chore:` Maintenance tasks
- **NEVER** mention AI/Claude authorship in commit messages.
