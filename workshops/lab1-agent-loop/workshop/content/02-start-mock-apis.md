---
title: Explore the Mock APIs
---

## Step 1 — Explore the Mock API Specs

The workshop uses three OpenAPI specs as stand-ins for real back-end systems.
There are **no running services** — Kong's Mocking plugin reads the `example`
fields directly from each spec and returns them as HTTP responses. The routes
were created by Terraform when your session started.

| Service | MCP endpoint | Tools it provides |
|---------|-------------|-------------------|
| Expense service | `$PROXY/mcp/expense` | `approveExpense`, `rejectExpense`, `escalateExpense` |
| HR service | `$PROXY/mcp/hr` | `getEmployee` (spending limits, department) |
| Policy service | `$PROXY/mcp/policy` | `getPolicy`, `evaluateExpense` |

### Read the expense spec

Take a moment to look at the expense service spec:

```terminal:execute
command: cat mock-apis/expense-service/openapi.yaml
```

Notice three things:

1. **Three action endpoints** — `/approve`, `/reject`, `/escalate`.
   Each `operationId` becomes the MCP tool name the agent will call.

2. **`example` in each 200 response** — this is exactly what Kong's Mocking
   plugin returns. No upstream logic is needed; the example payload is the
   response.

3. **No server block** — the spec describes the shape of the API, not where
   it runs. Kong handles routing and response fabrication.

### Read the policy spec

```terminal:execute
command: cat mock-apis/policy-service/openapi.yaml
```

Find the `example` under `GET /policy`. This is the policy the agent will
retrieve on every run: auto-approve limit, escalation threshold, restricted
categories. Understanding this example helps you predict what the agent will
decide before you run it.

### How the plugin chain works

Two Kong plugins are stacked on each MCP route and run in this order:

| Order | Plugin | What it does |
|-------|--------|-------------|
| 1 | **AI MCP Proxy** (`conversion-listener`) | Translates inbound MCP `tools/call` JSON into a REST request |
| 2 | **Mocking** | Intercepts the REST request *before* it leaves Kong and returns the spec `example` — the upstream is never contacted |

The AI MCP Proxy then translates the REST response back into an MCP result
and returns it to the caller. The upstream URL (`http://mock-expense.internal`)
is a placeholder that is never resolved.

### Inspect the Kong configuration

The config that was applied by Terraform is available to read:

```terminal:execute
command: cat decK/lab1-agent-loop/kong.yaml
```

Find the plugin stanza for `expense-mcp` and confirm the two plugins are
declared in the order above. There is nothing to sync — this exists only so
you can understand exactly what Kong is doing on each tool call.

---

→ Continue to **Verify the MCP Tools**
