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
├── routes/                # API route handlers (file-based routing)
│   └── index.dart         # GET /
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
