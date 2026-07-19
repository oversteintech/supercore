# ADR-007 — Safe composition defaults (BootstrapMode)

**Status:** Accepted  
**Date:** 2026-07-19

## Context

In-memory / mock providers boot as if production, hiding missing adapters until production load.

## Decision

```dart
enum AfterBootstrapMode { scaffold, production }
```

- `scaffold` (default for templates) → in-memory OK.
- `production` → missing adapter throws at startup.

Apply to ecosystem fabric and enterprise repository providers.

## Consequences

Templates and demos stay productive; production builds fail fast when adapters are missing.
