---
title: Overview
---

## Lab 3 — LLM Governance

In Lab 1 you configured the `/llm` route on your AI Gateway and pointed the
agent at it. Every LLM call already flows through Kong. In Lab 2 you added
OAuth2-gated MCP tool access so the agent reasons with company policy before
deciding.

The data path at the start of this lab looks like this:

```
Agent  ──▶  Kong /llm         ──▶  OpenAI     ← visible, but ungoverned
Agent  ──▶  Kong /mcp/policy  ──▶  Policy MCP ← OAuth2 secured
```

The gateway is in the path — but the `/llm` route has no spend controls,
no fallback if OpenAI goes down, and no protection against prompt injection.
This lab adds all of that, one plugin at a time.

### What you'll do

```
Lab 3 result:
  Agent ──▶ Kong /llm ──▶ AI Rate Limit ──▶ AI Prompt Guard
                      ──▶ AI Proxy (OpenAI → Anthropic fallback)
                      ──▶ AI Semantic Cache
                      ──▶ OpenAI / Anthropic
```

1. **Control spend** — add token-based rate limiting per consumer
2. **Add failover** — configure a secondary LLM provider so the agent
   survives an OpenAI outage
3. **Add guardrails** — block prompt injection attempts before they reach
   the model
4. **Enable semantic caching** — return cached responses for similar
   prompts, cutting cost and latency
5. **Observe the full path** — see every MCP tool call and every LLM call
   in one analytics view

Zero agent code changes. Everything is Kong configuration.

---

→ Continue to **Control Spend**
