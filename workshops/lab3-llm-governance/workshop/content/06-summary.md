---
title: Summary
---

## Lab 3 Complete — The Core Series is Done

You have built a production-grade governed agent data path across three labs:

```
Expense Agent
  │
  ├── /llm  ──▶ Kong ──▶ AI Rate Limit + AI Prompt Guard + AI Semantic Cache
  │                  ──▶ AI Proxy ──▶ OpenAI (primary) / Anthropic (fallback)
  │
  └── /mcp/policy ──▶ Kong ──▶ AI MCP OAuth2 ──▶ Policy MCP Server
                              token validated via Kong Identity
```

### What you added in this lab — without changing agent code

| Capability | Plugin |
|------------|--------|
| LLM spend control (per consumer, per token) | AI Rate Limiting Advanced |
| LLM provider resilience | AI Proxy (`fallback_models`) |
| Prompt injection protection | AI Prompt Guard |
| Redundant LLM call elimination | AI Semantic Cache |

### The full picture across all three labs

| Lab | What you governed | How |
|-----|-------------------|-----|
| Lab 1 | LLM calls | AI Proxy plugin + vault-stored credentials |
| Lab 2 | MCP tool access | AI MCP OAuth2 + Kong Identity |
| Lab 3 | LLM spend, resilience, safety, efficiency | Rate Limit + Failover + Guardrails + Cache |

### The outside-in principle in practice

Three labs. Eight capabilities added. The agent code received exactly **one
meaningful change**: the LLM Proxy URL set in Lab 1. Everything else was
Kong configuration — deployed, versioned, and rollable without touching the
agent.

---

## Optional challenges

- Add a second agent consumer (`expense-agent-readonly`) that can call
  `/mcp/policy` but has a lower token rate limit. Observe how the analytics
  distinguish the two identities.
- Use the **Request Transformer** plugin to inject a `X-Agent-Run-ID` header
  on every LLM call. Observe it in the logs.
- Lower the semantic cache similarity threshold to `0.85` and run a wider
  variety of expense prompts. Observe how the cache hit rate changes.
