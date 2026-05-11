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
lib/auth/        # Auth helpers (JWT, claims, user store)
routes/          # API endpoints (file-based routing)
test/            # Tests
```

## Authentication

All routes except `/auth/*` require a Bearer token. Set the `JWT_SECRET` environment variable in production.

```
# Get a token
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Use the token
curl http://localhost:8080/ -H "Authorization: Bearer <token>"
```

Default credentials: `admin` / `admin123` (configured in `lib/auth/users.dart`).

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST   | /auth/login | Authenticate and receive a JWT |
| GET    | /    | Welcome message (protected) |
