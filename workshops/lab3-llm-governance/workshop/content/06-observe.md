---
title: Observe the Full Data Path
---

## Step 6 — The Complete Picture

Run the agent one more time:

```bash
npm run dev -- "Bob (emp-002) is submitting \$2500 for a conference in Austin"
```

Open **Konnect Analytics → Requests** and filter to the last 2 minutes.
You will see the complete data path in one log view:

| Route | Method | Status | Latency | Consumer | Cache |
|-------|--------|--------|---------|----------|-------|
| `/llm` | POST | 200 | 1.2s | expense-agent | Miss |
| `/mcp/policy` | POST | 200 | 8ms | expense-agent | — |
| `/mcp/hr` | POST | 200 | 6ms | expense-agent | — |
| `/mcp/policy` | POST | 200 | 7ms | expense-agent | — |
| `/mcp/expense` | POST | 200 | 9ms | expense-agent | — |
| `/llm` | POST | 200 | 180ms | expense-agent | Hit |

Notice:
- The LLM is called first (agent reasoning), and again near the end (response
  synthesis). The second call may hit the semantic cache.
- All MCP tool calls are sub-10ms — the mock APIs are local, but in
  production these would be governed backend services.
- Every single hop is attributed to `expense-agent`.

### The full governed data path

```
Client
  │
  ▼
Kong  (Key Auth + ACL)
  │
  ├──▶  /llm         (AI Proxy, Rate Limit, Guardrails, Semantic Cache)
  │         │
  │         ▼
  │       OpenAI / Anthropic (failover)
  │
  └── Tool routes:
      ├── /mcp/expense  (Key Auth, ACL, AI MCP Proxy)
      ├── /mcp/hr       (Key Auth, AI MCP Proxy)
      └── /mcp/policy   (Key Auth, AI MCP Proxy)
```

Every hop is observable. Every hop is controllable.
The agent code has not changed since Lab 1.

---

→ Continue to **Summary**
