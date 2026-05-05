---
title: Summary
---

## Lab 1 Complete

You have explored the full baseline data path:

```
Expense Agent UI
  │
  ▼
Kong Serverless Gateway
  ├── /mcp/expense  ──▶  expense-service  (Mocking plugin)
  ├── /mcp/hr       ──▶  hr-service       (Mocking plugin)
  └── /mcp/policy   ──▶  policy-service   (Mocking plugin)
  │
  ▼
Volcano Agent  ──▶  LLM (OpenAI direct — no gateway yet)
```

### What you learned

- Kong's **AI MCP Proxy Plugin** in `conversion-listener` mode converts any
  OpenAPI-described REST API into an MCP server with zero upstream changes.
- Kong's **Mocking plugin** intercepts requests and returns `example` payloads
  from the spec — no real services needed in this lab.
- Volcano agents are MCP-native: they declare tool servers by URL and the SDK
  handles the MCP protocol entirely.
- Every tool call passes through Kong — which means every tool call is
  observable and, from Lab 2 onwards, controllable.
- The Expense Agent UI is a containerised Express + static-HTML app deployed
  inside your Educates session; all config (proxy URL, API key) is entered
  via the browser.

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
  when `requiresReceipt` is `true` in the expense evaluation response.
- Deliberately misconfigure one MCP route in the Agent UI (point it at a
  non-existent path) and observe how the agent handles a tool call failure.
- Use the MCP Inspector dashboard to call `evaluateExpense` manually with
  different amounts and see how the policy spec example drives the response.

---

## Next: Lab 2 — Auth & Tool Access Control

In Lab 2 you will add key authentication to the tool routes and create a
named Kong consumer for the agent, giving Kong a first-class identity to
enforce access control against.

[→ Start Lab 2](../../lab2-auth-tool-access/)
