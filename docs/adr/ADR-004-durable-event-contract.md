# ADR-004 — Durable event contract

**Status:** Accepted  
**Date:** 2026-07-19

## Context

`InMemoryAfterEventBus` is a 500-cap RAM bus presented as production fabric. Events lack schema version, idempotency, and partition keys; `sourceProductId` is spoofable.

## Decision

Extend `AfterEcosystemEvent` with:

- `schemaVersion`
- `idempotencyKey`
- `partitionKey` (afterId or orgId)
- optional `signature`

Rules:

- `InMemoryAfterEventBus` = **test/scaffold only**, gated by bootstrap mode.
- Production adapters implement the same port without rewrite.
- `publish` rejects unsigned/spoofed source when a signing key is configured.
- History via cursor, not 500-cap only.

## Consequences

Phase 1 hardens the envelope and cursor history API. Real Kafka/PubSub adapters are out of Phase 1 scope.
