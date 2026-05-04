---
title: Summary
---

## Lab 4 Complete — The Full Data Path

You have added event streaming to the governed data path with zero changes
to the agent or the back-end services:

```
Client
  │
  ▼
Kong
  │
  ├── /llm           AI Proxy + Rate Limit + Guardrails + Cache
  │     └──▶  LLM
  │
  ├── /mcp/hr        AI MCP Proxy + Key Auth
  │     └──▶  hr-service
  │
  ├── /mcp/policy    AI MCP Proxy + Key Auth
  │     └──▶  policy-service
  │
  └── /mcp/expense   AI MCP Proxy + Key Auth + ACL + Kafka Log
        ├──▶  expense-service
        └──▶  Kafka: expense-decisions  ──▶  anomaly detection
                                        ──▶  compliance audit
                                        ──▶  workflow triggers
                                        ──▶  policy hot-reload
```

### The complete governance stack

| Layer | What Kong controls |
|-------|--------------------|
| Identity | Who is calling (Key Auth + consumers) |
| Access | What they're allowed to call (ACL) |
| LLM spend | How much they can call the LLM (AI Rate Limiting) |
| LLM resilience | What happens when the LLM is down (failover) |
| Prompt safety | What they're allowed to send (AI Prompt Guard) |
| Efficiency | Whether to call the LLM at all (Semantic Cache) |
| Audit | A record of every decision, forever (Kafka Log) |

### No agent code was changed after Lab 1

Every layer of governance in this workshop was added through Kong
configuration. The Volcano agent code is unchanged from when you first ran
it. That's the outside-in principle: the system around the agent is what
makes it safe to run in production.

---

## What to explore next

- **Kong Konnect MCP Registry** (Kong MCP Workshop — Lab 3): centralise
  discovery of approved MCP servers across your engineering org.
- **OpenTelemetry plugin**: export full distributed traces from Kong to
  Jaeger, Datadog, or Honeycomb — visualise the agent reasoning tree.
- **Request Transformer Advanced**: enrich every tool call with metadata
  (run ID, user context) before it reaches the upstream service.
- **Webhooks / HTTP Log plugin**: push events to your SIEM or incident
  management system in real time.
