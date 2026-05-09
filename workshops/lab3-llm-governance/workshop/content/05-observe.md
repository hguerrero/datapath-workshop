---
title: Observe the Full Path
---

## Step 5 — The Complete Picture

Run the agent one more time with an escalation-worthy expense:

> *Bob (emp-002) is submitting $2,500 for a conference in Austin.*

Open **Konnect Analytics → Requests** and filter to the last 2 minutes.
You will see the complete data path in one log view:

| Route | Status | Latency | Consumer | Cache |
|-------|--------|---------|----------|-------|
| `/llm` | 200 | ~1.2s | expense-agent | Miss |
| `/mcp/policy` | 200 | ~8ms | — | — |
| `/mcp/hr` | 200 | ~6ms | — | — |
| `/mcp/policy` | 200 | ~7ms | — | — |
| `/mcp/expense` | 200 | ~9ms | — | — |
| `/llm` | 200 | ~90ms | expense-agent | Hit |

Notice:

- The LLM is called first (initial reasoning) and again at the end (response
  synthesis). The second call often hits the semantic cache.
- All MCP tool calls are sub-10ms.
- The first LLM call shows `expense-agent` as the consumer — rate limiting
  and guardrails are applied against this identity.

### The full governed data path

```
Expense Agent
  │
  ├── /llm  ─────▶ Kong (Rate Limit + Prompt Guard + Semantic Cache)
  │                    └──▶ AI Proxy ──▶ OpenAI (primary)
  │                                  └──▶ Anthropic (fallback)
  │
  └── /mcp/policy ──▶ Kong (AI MCP OAuth2) ──▶ Policy MCP Server
```

Every hop is observable. Every hop is controllable.
The agent code has not changed since Lab 1.

---

→ Continue to **Summary**
