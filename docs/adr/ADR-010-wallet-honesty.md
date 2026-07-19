# ADR-010 — Wallet honesty

**Status:** Accepted  
**Date:** 2026-07-19

## Context

Ledger-only APIs are named "Wallet", implying payment rails that do not exist.

## Decision

Rename ledger API to `AfterWalletLedger` (or document clearly as ledger-only until Phase 2 real wallet). Do not claim payment rails until designed.

## Consequences

Phase 1 documents honesty in API docs / type aliases where low-risk; full payment wallet is out of scope.
