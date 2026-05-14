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
- JWT auth via `dart_jsonwebtoken`
- Password hashing via `bcrypt`
- SQLite via `sqflite_common_ffi` (in-memory store used in dev by default)

## Project Structure

```
root/
├── lib/auth/
│   ├── claims.dart              # AuthClaims model
│   ├── jwt.dart                 # JWT sign/verify
│   ├── user.dart                # User model
│   ├── user_store.dart          # Abstract UserStore interface
│   ├── in_memory_user_store.dart # In-memory UserStore (dev default)
│   ├── sqlite_user_store.dart   # SQLite-backed UserStore
│   ├── password_hasher.dart     # bcrypt password hashing
│   └── migration_runner.dart    # Runs SQL migration files
├── migrations/
│   └── 001_create_users.sql     # Users table schema
├── routes/
│   ├── _middleware.dart         # Global auth + DI (UserStore, PasswordHasher)
│   ├── index.dart               # GET / (protected)
│   ├── auth/
│   │   ├── login.dart           # POST /auth/login
│   │   └── register.dart        # POST /auth/register
│   └── users/
│       ├── index.dart           # GET /users
│       └── [id].dart            # GET/PUT/DELETE /users/:id
├── test/
│   ├── routes/
│   │   ├── index_test.dart
│   │   └── auth/
│   │       ├── login_test.dart
│   │       └── register_test.dart
│   └── lib/auth/
│       ├── password_hasher_test.dart
│       └── user_store_test.dart
├── pubspec.yaml
└── analysis_options.yaml
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
dart test test/routes/auth/register_test.dart  # Run specific test file
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
- **Register**: `POST /auth/register` with `{"username": "...", "password": "...", "email?": "..."}` returns the created user.
- **Protected routes**: all routes except `/auth/*` require `Authorization: Bearer <token>`.
- **User identity**: after auth, route handlers access the user via `context.read<AuthClaims>()`.

### User Store

`UserStore` is an abstract interface with two implementations:

- **InMemoryUserStore** — used by default in dev. No external dependencies.
- **SqliteUserStore** — SQLite-backed. To switch, update `routes/_middleware.dart` to initialize and provide a `SqliteUserStore` instead.

Both implementations take a `PasswordHasher` via constructor injection.

### Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST   | /auth/login | No | Authenticate, receive JWT |
| POST   | /auth/register | No | Create new user account |
| GET    | /      | Bearer | Welcome message |
| GET    | /users | Bearer | List all users |
| GET    | /users/:id | Bearer | Get user by ID |
| PUT    | /users/:id | Bearer | Update user |
| DELETE | /users/:id | Bearer | Delete user |

### File-based routing
- `routes/index.dart` → `GET /`
- `routes/users/index.dart` → `GET /users`
- `routes/users/[id].dart` → `GET/PUT/DELETE /users/:id`
- `routes/auth/login.dart` → `POST /auth/login`
- `routes/auth/register.dart` → `POST /auth/register`
- Each route file exports an `onRequest(RequestContext)` function.
- Dynamic segments use `[param].dart` filename syntax.

### Middleware
- Global middleware goes in `routes/_middleware.dart`.
- Subdirectory middleware (`routes/foo/_middleware.dart`) applies only to routes under that directory.
- Use `handler.use(provider<T>(...))` to inject dependencies into `RequestContext`.

### Dependency injection
- Use `provider<T>(factory)` in middleware to make dependencies available.
- Routes retrieve them via `context.read<T>()`.
- Singleton services (UserStore, PasswordHasher) are instantiated at module level and returned by the provider factory.

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
