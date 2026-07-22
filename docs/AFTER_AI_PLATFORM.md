# AfterAI Platform

**Status:** Active  
**Package:** [`packages/after_ai`](../packages/after_ai)  
**Kernel bridge:** [`packages/after_core`](../packages/after_core) (`AfterAiClient`, BYOK vault, orchestrator)  
**Rule:** Every Life Domain / Industry Domain module uses **the same AI platform**.
Products only enable or disable capabilities and register domain skills.

There is **one After AI assistant** across the ecosystem. Life Domains
(Garage, Health, Kids, Sports, Games, …) extend it — they never ship a
private assistant. Cross-domain awareness requires
`AfterEcosystemAiContext` from `after_ecosystem`.

Vision: [`LIFE_DOMAINS.md`](LIFE_DOMAINS.md).

---

## 1. Why a single AI platform

Without AfterAI, each Super App invents its own chat stack, OCR glue, and prompt files → inconsistency, security drift, and duplicated cost.

With AfterAI:

| Layer | Owner |
|-------|--------|
| Capabilities, ports, mocks, profiles, tool/plugin contracts | `after_ai` |
| LLM transport, BYOK credential vault, provider kinds | `after_core` |
| Ecosystem context (cross-Life-Domain graph) | `after_ecosystem` |
| Tenant-scoped assistant wrapper | `after_enterprise` (`EnterpriseAiAssistant`) |
| Domain skills / tools / KB content | Product repo only |

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Super App (domain)                       │
│  AfterAiProfile { enabled capabilities + skills/tools }      │
└───────────────────────────┬─────────────────────────────────┘
                            │ Riverpod: afterAiPlatformProvider
┌───────────────────────────▼─────────────────────────────────┐
│                      AfterAiPlatform                         │
│  Façade — enforce profile gates, route online/offline        │
└───┬─────────┬─────────┬─────────┬─────────┬─────────────────┘
    │         │         │         │         │
 Conversation Vision  OCR/STT  Search/KB  Tools/Plugins …
    │         │         │         │         │
 Mock* or production adapters (cloud / on-device)
    │
    └── OnlineAi MAY bridge → after_core AfterAiClient (BYOK)
```

---

## 3. Capability catalog

| Capability | Use |
|------------|-----|
| Conversation AI | Mate chat, multi-turn |
| Vision AI | Image understanding |
| OCR | Documents, plates, labels |
| Speech To Text | Dictation, clinical notes |
| Text To Speech | Accessibility, briefings |
| Translation | Locale expansion |
| Recommendation Engine | Feed / upsell / next action |
| Prediction Engine | Risk / demand / failure scores |
| Summarization | News, records, threads |
| Semantic Search | Cross-entity retrieval |
| Knowledge Base | Product manuals, SOPs, policies |
| Automation | Playbooks / agents |
| Decision Support | Structured advise + confidence |
| Notifications | AI-suggested alerts |
| Workflow Suggestions | Next-best workflow steps |
| Context Memory | Session / user memory |
| Offline AI | On-device / cached inference |
| Online AI | Cloud LLMs (BYOK) |
| Prompt Templates | Versioned prompts |
| Tool Calling | Structured function calls |
| AI Plugins | Installable capability packs |

---

## 4. What a Super App configures

**Only this:**

```dart
afterAiProfileProvider.overrideWithValue(
  AfterAiProfile(
    appId: 'super_airport',
    enabled: {
      AfterAiCapability.conversation,
      AfterAiCapability.summarization,
      AfterAiCapability.decisionSupport,
      AfterAiCapability.workflowSuggestions,
      AfterAiCapability.onlineAi,
      AfterAiCapability.offlineAi,
      AfterAiCapability.promptTemplates,
      AfterAiCapability.toolCalling,
      AfterAiCapability.contextMemory,
    },
  ),
);
```

Or use a reference profile:

- `AfterAiProfile.superGarage`
- `AfterAiProfile.superHospital`
- `AfterAiProfile.superNews`
- `AfterAiProfile.conversationOnly(appId)`

Calling a disabled capability throws `AfterAiCapabilityDisabledException`.

---

## 5. Reference profiles

| App | Life / Industry Domain | Emphasis |
|-----|------------------------|----------|
| **SuperGarage** | Mobility | Conversation, OCR, vision, prediction, tools, KB |
| **SuperHospital** | Hospital ops | Decision support, STT/TTS, translation, workflow suggestions, automation |
| **SuperNews** | Information | Summarization, translation, recommendation, TTS, semantic search |
| **SuperKids** *(skills)* | Family & parenting | Conversation, reminders, summarization, tools (vaccines, school, tasks) |
| **SuperSports** *(skills)* | Sport & performance | Conversation, prediction, summarization, recommendation (match + fitness) |
| **SuperGames** *(skills)* | Gaming | Recommendation, summarization, conversation (library / wishlist) |
| **SuperFind** *(skills)* | Presence & safety | ETA, anomaly, place recognition, mobility summary, forgotten vehicle |

---

## 6. Online vs offline

`AfterAiPlatform.complete(prompt)`:

1. If `preferOffline` and offline available → offline
2. Else if online enabled and available → online (bridge to BYOK)
3. Else offline fallback
4. Else throw

Production apps inject:

```dart
AfterAiPlatform(
  profile: AfterAiProfile.superGarage,
  onlineAi: MockAfterOnlineAi(
    delegate: (prompt) => orchestrator.handle(userMessage: prompt)
        .then((r) => r.text),
  ),
);
```

---

## 7. Tools, prompts, plugins

- **Prompt templates** — `{{variables}}` rendered at call time; store per app/locale.
- **Tool calling** — plan → invoke; register domain handlers in product composition root.
- **Plugins** — descriptor registry for installable packs (e.g. VIN plugin, FHIR plugin).

Domain tools live in the product repo; the platform only provides the bus.

---

## 8. Security & compliance

- BYOK keys only in `AfterAiCredentialVault` (secure storage) — never logs.
- Enterprise calls go through `EnterpriseAiAssistant` for org/role context + audit.
- Disabled capabilities fail closed.
- No product may embed a second LLM SDK for core Mate flows.

---

## 9. Adding a capability to the platform

1. Add enum value to `AfterAiCapability`.
2. Add port in `after_ai_ports.dart` + mock.
3. Wire field + gated method on `AfterAiPlatform`.
4. Update `MODULE` / this doc + tests.
5. Optionally enable in reference profiles.

Products never fork — they wait for the platform capability or contribute it upstream to `supercore`.

---

## 10. Consistency rule

> If two Super Apps need the same AI behavior, it belongs in **AfterAI**, not copy-pasted into both `lib/features/assistant/` folders.
