# After Hub — OS shell (not a Life Domain)

**Role:** `os_shell` · **Package:** `after_hub` · **Bundle:** `com.overstein.afterhub`

## Owns (UX only)
- Consumer entry chrome: Home, Calendar, Apps launcher, AI tab, More
- Federated Hub widget mosaic and layout personalization
- Surfaces for After ID, After+, Family, Notification/Document centers
- Aggregation APIs / event subscriptions for tile refresh

## Does not own
- Domain business logic (Garage, Health, Find, …)
- AI runtime (`after_ai`), BYOK (`after_core`)
- Calendar/search/documents/notification **data planes** (ecosystem ports)
- Enterprise org admin (enterprise apps)

## SuperAI
Hub **AI** tab **is** the SuperAI surface. See
[`SUPER_AI_DOMAIN.md`](SUPER_AI_DOMAIN.md) and [`AFTER_HUB.md`](../AFTER_HUB.md).

## Binding ADR
[`ADR-019-after-hub.md`](../adr/ADR-019-after-hub.md)
