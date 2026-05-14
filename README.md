# Dardo

REST API built with [Dart Frog](https://dartfrog.vgv.dev).

## Getting started

```bash
# Install dependencies
dart pub get

# Start dev server (hot reload enabled)
dart_frog dev
```

The server runs on `http://localhost:8080`.

## Project layout

```
lib/auth/        # Auth helpers (JWT, claims, user store, password hashing)
migrations/      # Database migration SQL files
routes/          # API endpoints (file-based routing)
test/            # Tests
```

## Authentication

All routes except `/auth/*` require a Bearer token. Set the `JWT_SECRET` environment variable in production.

```
# Register a new user
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"alice","password":"secret123"}'

# Login to get a token
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"alice","password":"secret123"}'

# Use the token
curl http://localhost:8080/ -H "Authorization: Bearer <token>"
```

## Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST   | /auth/login | No | Authenticate and receive a JWT |
| POST   | /auth/register | No | Create a new user account |
| GET    | /    | Bearer | Welcome message |
| GET    | /users | Bearer | List all users |
| GET    | /users/:id | Bearer | Get user by ID |
| PUT    | /users/:id | Bearer | Update user |
| DELETE | /users/:id | Bearer | Delete user |

## User Store

User data is stored via the abstract `UserStore` interface. Two implementations are included:

- **InMemoryUserStore** — dev default, no external dependencies.
- **SqliteUserStore** — SQLite-backed, for production use.

Passwords are hashed with bcrypt before storage.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| JWT_SECRET | dev-secret | Secret key for signing JWTs |
