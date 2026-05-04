---
title: Overview
---

## Lab 2 — Auth & Tool Access Control

In Lab 1 you built a working agent loop. Every tool route through Kong was
wide open — any caller, any tool, no questions asked.

This lab closes that gap. You will:

1. Add **key authentication** to all three MCP tool routes
2. Create a named Kong **consumer** for the `expense-agent`
3. Issue an API key and configure the agent to send it
4. Use **ACL groups** to restrict which consumers can call which tools
5. Verify that unauthorized calls are rejected at the gateway

### The governance insight

You will not change a single line of agent code to enforce access control.
You change Kong configuration. The agent picks up its API key from an
environment variable — the same pattern you would use in CI/CD, secrets
managers, or Konnect Vaults.

```
Before:  any caller  ──▶  Kong  ──▶  any tool
After:   expense-agent (with key)  ──▶  Kong  ──▶  allowed tools only
         unknown caller              ──▶  Kong  ──▶  401 Unauthorized
```

---

→ Continue to **The Problem**
