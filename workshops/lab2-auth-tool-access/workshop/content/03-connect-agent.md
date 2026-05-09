---
title: Connect the Agent
---

## Step 3 — Point the Agent at Kong

You already have your gateway's Proxy URL from Lab 1. Paste it into the
agent so it can route MCP tool calls — including `getPolicy` — through Kong.

### Configure the agent

```dashboard:open-dashboard
name: Expense Agent
```

Paste your Proxy URL into the **Proxy URL** field and click **Save Config**.

> **Leave the Agent API Key field empty for now** — the MCP server is
> currently unauthenticated. We'll add the key in Step 5 after locking it
> down.

That's it. The agent will now discover and call MCP tools via Kong on every
run.

---

→ Continue to **Policy in Action**
