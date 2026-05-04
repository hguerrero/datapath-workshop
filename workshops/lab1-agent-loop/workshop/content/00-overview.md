---
title: Overview
---

## Lab 1 — The Agent Loop

In this lab you will wire up a complete AI agent data path from scratch:

```
Client
  │
  ▼
Kong Serverless Gateway   ←── the control plane for every hop
  │
  ├── /mcp/expense  ──▶  expense-service  (approve / reject / escalate)
  ├── /mcp/hr       ──▶  hr-service       (employee & department lookup)
  └── /mcp/policy   ──▶  policy-service   (policy rules & evaluation)
  │
  ▼
Volcano Agent
  │
  ▼
LLM  (OpenAI via direct call — no gateway yet, that's Lab 3)
```

The agent is built with the [Volcano Agent SDK](https://volcano.dev) — an
MCP-native TypeScript framework. It connects to three mock back-end services,
all exposed as MCP tools by Kong's **AI MCP Proxy Plugin** in
`conversion-listener` mode. If you completed the Kong MCP Workshop, you have
already used this plugin; the technique here is identical.

### What you'll do

1. Start the three mock APIs
2. Configure Kong routes and attach the AI MCP Proxy Plugin to each one
3. Point the Volcano agent at the Kong MCP endpoints
4. Run an expense and watch the agent reason and act
5. Trace every request in the Kong logs

### Mental model — outside-in

Agents are autonomous, but autonomy without governance creates risk.
This workshop teaches you to think **outside-in**: start with the control
plane (Kong) and work inward toward the agent, never the other way around.

Every step you take in this lab adds a control point. By the end of Lab 3
you will have one without changing a single line of agent code.

---

→ Continue to **Prerequisites**
