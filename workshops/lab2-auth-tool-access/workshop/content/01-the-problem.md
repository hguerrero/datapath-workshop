---
title: The Problem
---

## Step 1 — See the Gap

From Lab 1, your tool routes are unauthenticated. Prove it:

```bash
curl -s -X POST $PROXY/mcp/expense \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}' | jq
```

That works for anyone with the URL — no credentials needed. In production
this means:

- **Any service** (or attacker) can call the `escalateExpense` tool
- **Any script** can approve or reject expenses by calling the tools directly
- There is no record of *who* called *what* — just that a call happened

Now try directly invoking the escalate tool (bypassing the agent entirely):

```bash
curl -s -X POST $PROXY/mcp/expense \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "id": 1,
    "params": {
      "name": "escalateExpense",
      "arguments": {
        "amount": 99999,
        "description": "Suspicious direct call",
        "employeeId": "unknown"
      }
    }
  }' | jq
```

It works. An escalation just got recorded with no agent involvement.

By the end of this lab that call will return `401 Unauthorized`.

---

→ Continue to **Add Key Authentication**
