---
title: Summary
---

## Lab 1 Complete

You have built the full baseline data path:

```
Client
  │
  ▼
Kong Serverless Gateway
  ├── /mcp/expense  ──▶  expense-service
  ├── /mcp/hr       ──▶  hr-service
  └── /mcp/policy   ──▶  policy-service
  │
  ▼
Volcano Agent  ──▶  LLM (direct — no gateway yet)
```

### What you learned

- Kong's AI MCP Proxy Plugin in `conversion-listener` mode converts any
  OpenAPI-described REST API into an MCP server with zero upstream changes.
- Volcano agents are MCP-native: they declare tool servers by URL and the
  SDK handles the protocol entirely.
- Every tool call passes through Kong — which means every tool call is
  observable and (soon) controllable.

### What's missing

Right now there are no guardrails:

- Any client can call any tool route — no authentication required
- The agent can call tools as fast as it wants — no rate limits
- The LLM call bypasses Kong entirely — no observability or failover
- There is no audit trail of decisions

Labs 2 and 3 fix all of this, one layer at a time.

---

## Optional challenges

- Add a fourth mock service (e.g. a `receipt-service`) and expose it as an
  MCP tool. Update the agent system prompt to require a receipt lookup
  when `requiresReceipt` is `true`.
- Deliberately break one of the mock API routes in Kong (wrong upstream URL)
  and observe how the agent handles a tool call failure.

---

## Next: Lab 2 — Auth & Tool Access Control

In Lab 2 you will add key authentication to the tool routes and create a
named Kong consumer for the agent, giving Kong a first-class identity to
enforce access control against.

[→ Start Lab 2](../../lab2-auth-tool-access/)
