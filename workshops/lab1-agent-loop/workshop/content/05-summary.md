---
title: Summary
---

### Lab 1 Complete

You built the first governance layer — starting from the outside, exactly
as the model demands.

### The data path after Lab 1

```
Expense Agent UI
  │
  ▼  (LLM Proxy = $LLM_PROXY_URL/llm)
Kong AI Gateway
  └── /llm  ──(ai-proxy + vault key)──▶  OpenAI   ← governed ✓
```

### What you did

- Created a Kong AI Gateway in Konnect and defined a route on `/llm`
- Connected OpenAI as the LLM provider using a key stored in the vault
- Set the agent's **LLM Proxy** to your AI Gateway URL — no key in the agent
- Ran expense scenarios and confirmed the decisions were unchanged
- Observed every LLM call in Analytics and the pre-built AI Gateway dashboard

### What you gained — without changing agent code

- **Credential isolation** — the OpenAI key lives in the vault, not the agent
- **Full LLM observability** — model, tokens, latency, and status on every call
- **A single control point** — one place to change model, add limits, or swap providers

### What comes next

The agent's tool calls — policy lookup, HR lookup, expense recording —
still go unobserved and unauthenticated. In Lab 2 you will add key
authentication to the MCP tool routes so Kong knows exactly which agent
is calling, and can enforce per-agent access control on every tool.

---

## Optional challenges

- In the Konnect AI Gateway, change the model from `gpt-4o-mini` to `gpt-4o`
  and re-run the conference trip expense. Does the reasoning change? Does latency?
- Run 10 expenses in quick succession. Check the Token usage panel in the
  dashboard — can you see the spike? What would a token rate limit look like?
- Try sending a direct curl to your `/llm` route without any body. What does
  Kong return? What does the AI status codes panel show afterwards?

---

## Next: Lab 2 — Auth & Tool Access Control

In Lab 2 you will add key authentication to the MCP tool routes and create
a named Kong consumer for the agent, giving Kong a first-class identity to
enforce access control on every tool call.

[→ Start Lab 2](../../lab2-auth-tool-access/)
