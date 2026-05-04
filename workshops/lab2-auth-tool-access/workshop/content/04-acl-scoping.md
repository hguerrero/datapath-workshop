---
title: Scope Tool Access with ACLs
---

## Step 4 — Restrict Which Tools Each Consumer Can Call

Key auth tells Kong *who* is calling. ACL groups tell Kong *what* they're
allowed to call. Together they give you role-based tool access.

### Create ACL groups

Assign the `expense-agent` consumer to an ACL group:

```bash
curl -s -X POST $PROXY/konnect-admin/consumers/expense-agent/acls \
  -H "Content-Type: application/json" \
  -d '{"group": "expense-agents"}' | jq
```

### Add ACL plugin to the escalate route

The `escalateExpense` tool is the highest-risk action — it creates human
review tickets and notifies managers. Let's restrict it to a separate group
(`escalation-approved`) that the base `expense-agent` consumer is *not* in.

In the Konnect UI, navigate to your `expense-mcp` route and add the
**ACL** plugin with:

| Field | Value |
|-------|-------|
| allow | `escalation-approved` |

> This means only consumers in the `escalation-approved` group can call
> this route at all.

### Test the restriction

With the current `expense-agent` consumer (group: `expense-agents`):

```bash
curl -s -X POST $PROXY/mcp/expense \
  -H "Content-Type: application/json" \
  -H "apikey: $AGENT_API_KEY" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "id": 1,
    "params": {
      "name": "escalateExpense",
      "arguments": {"amount": 5000, "description": "Test", "employeeId": "emp-001"}
    }
  }' | jq
```

Expected: `403 Forbidden` ✓

### Grant escalation rights

To allow escalation, add the consumer to the right group:

```bash
curl -s -X POST $PROXY/konnect-admin/consumers/expense-agent/acls \
  -H "Content-Type: application/json" \
  -d '{"group": "escalation-approved"}' | jq
```

Retry the call — it should now succeed.

### The governance pattern

You have just demonstrated **externally-enforced tool scoping**: the agent
code hasn't changed, but Kong decides whether any given tool call is
permitted based on the caller's group membership. Add a new agent consumer
with narrower groups and it will have a subset of tools available — no code
changes needed.

---

→ Continue to **Test Access Control End-to-End**
