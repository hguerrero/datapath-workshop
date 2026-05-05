---
title: Your Environment
---

## Step 0 — Verify Your Environment

Everything you need is already running. This step confirms the key pieces
are healthy before you go further.

### Check your session variables

Your Terraform-provisioned gateway URL is injected automatically:

```terminal:execute
command: echo "Gateway : $PROXY" && echo "Agent UI : $AGENT_URL"
```

You should see two HTTPS URLs. Keep `$PROXY` handy — you will paste it into
the Agent UI in the next step.

### Confirm the gateway is reachable

```terminal:execute
command: curl -s -o /dev/null -w "%{http_code}" $PROXY/ && echo ""
```

A `404` is expected — it means Kong is up but has no catch-all route.
Any other response (connection refused, timeout) means the gateway is not
yet ready; wait 30 seconds and retry.

### Confirm the MCP routes exist

```terminal:execute
command: curl -s -X POST $PROXY/mcp/policy \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}' \
  | jq '.result.tools[].name'
```

Expected output:

```
"getPolicy"
"evaluateExpense"
```

If you see this, all three MCP routes are up and serving tools.
If you get a 404 or connection error, let your instructor know — the
Terraform provisioning may still be completing.

### What you need to bring

The only thing **not** pre-provisioned is your **OpenAI API key**.
You will enter it directly in the Expense Agent UI in Step 2.

---

→ Continue to **Explore the Mock APIs**
