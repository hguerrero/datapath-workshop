---
title: Summary
---

## Lab 3 Complete — The Core Series is Done

You have built a production-grade governed agent data path:

```
Client
  │
  ▼
Kong  ←── the single control plane for everything below
  │
  ├── /llm          AI Proxy + Rate Limit + Guardrails + Semantic Cache
  │     └──▶  OpenAI (primary) / Anthropic (failover)
  │
  ├── /mcp/expense  AI MCP Proxy + Key Auth + ACL
  │     └──▶  expense-service
  │
  ├── /mcp/hr       AI MCP Proxy + Key Auth
  │     └──▶  hr-service
  │
  └── /mcp/policy   AI MCP Proxy + Key Auth
        └──▶  policy-service
```

### What you achieved — without changing agent code

| Capability | Plugin |
|------------|--------|
| MCP tool generation from REST APIs | AI MCP Proxy |
| Tool authentication | Key Auth |
| Tool access scoping | ACL |
| LLM call observability | AI Proxy |
| LLM spend control | AI Rate Limiting Advanced |
| LLM provider resilience | AI Proxy (fallback_models) |
| Prompt injection protection | AI Prompt Guard |
| Redundant LLM call elimination | AI Semantic Cache |

### The outside-in principle in practice

You added eight capabilities across three labs. The agent code received
exactly **one change**: an env variable swap in Lab 3 (`LLM_PROXY`).
Everything else was Kong configuration — deployed, versioned, and rolled
back without touching the agent.

---

## Optional challenges

- Add a second agent consumer (`expense-agent-readonly`) that can call
  `/mcp/hr` and `/mcp/policy` but not `/mcp/expense`. Watch how the
  agent fails gracefully when it can't act.
- Use the **Request Transformer** plugin to inject a `X-Agent-Run-ID` header
  on every tool call. Observe it in the logs.
- Enable the **OpenTelemetry** plugin and send traces to a local Jaeger
  instance. Visualise the full agent reasoning tree.

---

## Optional: Lab 4 — Kafka Event Trail

Lab 4 is independent — you don't need to have completed Lab 3 first, though
the concepts build naturally on top of it.

[→ Start Lab 4 (optional)](../../lab4-kafka-events/)
