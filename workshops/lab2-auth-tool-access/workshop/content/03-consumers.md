---
title: Create a Consumer
---

## Step 3 — Give the Agent an Identity

Create a Kong consumer for the agent and issue it an API key.

### Create the consumer

```bash
curl -s -X POST $PROXY/konnect-admin/consumers \
  -H "Content-Type: application/json" \
  -d '{"username": "expense-agent"}' | jq
```

> Or use the Konnect UI: **Consumers → New Consumer → username: expense-agent**

### Issue an API key

```bash
curl -s -X POST $PROXY/konnect-admin/consumers/expense-agent/key-auth | jq
```

Copy the `key` value from the response. This is your `AGENT_API_KEY`.

> **Workshop shortcut:** Your Educates session already has `$AGENT_API_KEY`
> pre-set by the instructor. You can skip issuing a new key and use that one.

### Configure the agent

Open `agent/.env` and set:

```
AGENT_API_KEY=<your-key-here>
```

Or use the pre-set session variable:

```bash
echo "AGENT_API_KEY=$AGENT_API_KEY" >> agent/.env
```

### Test the agent still works

```bash
cd agent && npm run dev
```

The agent should complete successfully. Internally it now sends
`apikey: <your-key>` on every MCP tool call — configured once in `agent.ts`
via the `authHeaders()` function.

### Verify the identity is visible in Kong logs

In Konnect Analytics, filter logs by the past 5 minutes. You should now see
a `consumer` field on every tool-call row, showing `expense-agent`.

Before this lab: anonymous requests, no accountability.
After this lab: every tool call is attributed to a named identity.

---

→ Continue to **Scope Tool Access with ACLs**
