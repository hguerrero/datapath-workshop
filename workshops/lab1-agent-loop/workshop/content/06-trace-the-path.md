---
title: Trace the Data Path
---

## Step 5 — Trace Every Hop

Open the **Konnect Analytics** page for your gateway. You will see one row
per request. For a typical approve scenario you should find something like:

| # | Method | Path | Status | Handled by |
|---|--------|------|--------|------------|
| 1 | POST | `/mcp/policy` | 200 | Mocking plugin (getPolicy) |
| 2 | POST | `/mcp/hr` | 200 | Mocking plugin (getEmployee) |
| 3 | POST | `/mcp/policy` | 200 | Mocking plugin (evaluateExpense) |
| 4 | POST | `/mcp/expense` | 200 | Mocking plugin (approveExpense) |

Notice there is **no upstream hostname** — `mock-expense.internal` and its
siblings are never resolved. Every response comes from the Mocking plugin
inside Kong based on the `example` values in each spec.

The LLM call does **not** appear in Kong logs yet. In Labs 1–2 the agent
calls the LLM provider directly, bypassing Kong. You'll fix that in Lab 3.

### Count the hops via Kong Admin

If you have access to the Admin API, you can query the request log:

```terminal:execute
command: curl -s "$KONNECT_ADMIN_URL/requests?page[size]=10" \
  -H "Authorization: Bearer $KONNECT_TOKEN" | jq '.data[] | {path, status}'
```

> In the Educates environment this data is also visible in the **Konnect UI →
> Analytics → Requests** table. The session URL is in your lab credentials.

### Inspect a mock response end-to-end

Call the expense escalate tool directly and watch the full response shape:

```terminal:execute
command: curl -s -X POST $PROXY/mcp/expense \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "id": 3,
    "params": {
      "name": "escalateExpense",
      "arguments": {
        "amount": 1500,
        "description": "Conference sponsorship",
        "employeeId": "emp-001"
      }
    }
  }' | jq '.'
```

The `result.content[0].text` field contains the JSON string from the
`/escalate` endpoint example in `mock-apis/expense-service/openapi.yaml`.
The Mocking plugin returned it; no external process was involved.

### Ask yourself

- What would happen if you removed the Mocking plugin from one route?
  (The request would reach `http://mock-*.internal` — and fail, because
  that host does not exist. The Mocking plugin is what makes the lab
  self-contained.)
- What would happen if you added a rate limit of 2 requests/minute to
  the `/mcp/policy` route?
- What if the `/mcp/expense/escalate` endpoint required an API key
  that the agent didn't have?

These are the questions Labs 2 and 3 will answer.

---

→ Continue to **Summary**
