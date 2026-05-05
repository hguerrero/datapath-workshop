---
title: Overview
---

## Lab 1 — The Agent Loop

In this lab you will explore a complete AI agent data path that has already
been provisioned for you by the workshop Terraform configuration:

```
Expense Agent UI  (dashboard tab)
  │
  ▼
Kong Serverless Gateway   ←── observability & control for every hop
  │
  ├── /mcp/expense  ──▶  expense-service  (approve / reject / escalate)
  ├── /mcp/hr       ──▶  hr-service       (employee & department lookup)
  └── /mcp/policy   ──▶  policy-service   (policy rules & evaluation)
  │
  ▼
LLM  (OpenAI — direct call; Kong AI Gateway is added in Lab 3)
```

The agent is built with the [Volcano Agent SDK](https://volcano.dev) — an
MCP-native TypeScript framework. The three back-end services are **mock APIs**:
Kong's Mocking plugin reads `example` payloads directly from each OpenAPI spec
and returns them as HTTP responses — no upstream processes needed.

### What's already running

| Component | Location |
|-----------|----------|
| Kong Serverless Gateway + MCP routes | `$PROXY` — see your terminal |
| Expense Agent UI | **Expense Agent** tab (top of this window) |
| MCP Inspector | **MCP Inspector** tab |

Everything above was provisioned by Terraform when your session started.
Your only job in this lab is to **connect your OpenAI key** to the agent and
observe the full data path in action.

### What you'll do

1. Verify the gateway and MCP tools are ready
2. Explore the mock API specs to understand how Kong serves them
3. Open the Expense Agent dashboard and enter your OpenAI API key
4. Run expense scenarios and observe the agent's decisions
5. Trace every request through Kong

### Mental model — outside-in

Agents are autonomous, but autonomy without governance creates risk.
This workshop teaches you to think **outside-in**: the control plane (Kong)
wraps the agent and you work inward — never the other way around.

Every lab adds a control point. By the end of Lab 3 you will have a fully
governed data path without changing a single line of agent code.

---

→ Continue to **Your Environment**
