---
title: Overview
---

### Lab 1 — The Agent Loop

You have a running expense-approval agent. It calls OpenAI directly.
You have zero visibility into those calls, no way to rate-limit them,
no way to rotate the API key without redeploying the agent.

This lab fixes that — before you touch the agent at all.

### The outside-in mental model

Every lab in this series adds governance by working **outside-in**: start
at the outermost boundary of the system, add a control point, then step
inward. Never start inside and work out.

```
┌──────────────────────────────────────────────────────────────┐
│  Kong Gateway                             ← you start here   │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  Agent reasoning loop                                  │  │
│  │  ┌──────────────────┐   ┌────────────────────────────┐ │  │
│  │  │  LLM (OpenAI)    │   │  MCP tools (policy/HR/exp) │ │  │
│  │  └──────────────────┘   └────────────────────────────┘ │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

The outermost boundary is the **LLM call**. Every time the agent reasons,
it calls OpenAI. That is the highest-value control point — and the one
you will govern in this lab.

### What you will do

1. Set your OpenAI API key in the session and confirm no `/llm` route exists yet
2. Define the `llm-service`, the `/llm` route, and the `ai-proxy` plugin in a decK config
3. Sync that config to your Kong gateway — the route is live
4. Open the Expense Agent, point it at `$PROXY/llm`, and leave its key field empty
5. Run expenses and watch Kong log every LLM call with model, tokens, and latency

### What you gain (without changing a line of agent code)

- **Credential isolation** — the OpenAI key lives in Kong; the agent never holds it
- **Full LLM observability** — every reasoning step is a logged Kong request
- **A platform** — rate limiting, failover, guardrails, and caching are one plugin away

---

→ Continue to **Your Environment**
