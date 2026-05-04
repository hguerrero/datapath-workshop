---
title: Expose APIs as MCP Tools
---

## Step 2 — Expose the REST APIs as MCP Tools via Kong

This step uses two Kong plugins working together on every tool route:

| Plugin | What it does |
|--------|-------------|
| **AI MCP Proxy** (`conversion-listener`) | Reads your OpenAPI spec and generates an MCP server from it. Translates inbound MCP tool calls into HTTP requests and outbound HTTP responses back into MCP responses. |
| **Mocking** | Intercepts each HTTP request *before* it reaches the upstream and returns the `example` payload from the spec. The upstream (`http://mock-*.internal`) is never contacted. |

Because the Mocking plugin short-circuits every call, there are **no upstream
services to start**. Kong handles the full round-trip.

### Sync the Lab 1 decK config

The pre-built config in `decK/lab1-agent-loop/kong.yaml` creates all three
services, routes, and plugins in one shot. Make sure you have set
`SPEC_BASE_URL`, `KONNECT_TOKEN`, and `CP_NAME`, then run:

```terminal:execute
command: deck gateway sync decK/lab1-agent-loop/kong.yaml \
  --konnect-token $KONNECT_TOKEN \
  --konnect-control-plane-name $CP_NAME \
  --env-var SPEC_BASE_URL=$SPEC_BASE_URL
```

decK will print a diff of what it is creating. You should see three services
(`expense-service`, `hr-service`, `policy-service`) and six plugins (two per
route).

### What the config does

Open `decK/lab1-agent-loop/kong.yaml` and find the `expense-mcp` route:

```terminal:execute
command: cat decK/lab1-agent-loop/kong.yaml
```

Notice the plugin chain on that route:

```yaml
plugins:
  - name: ai-mcp-proxy
    config:
      mode: conversion-listener
      upstream_path: /
      spec:
        url: $SPEC_BASE_URL/expense-service/openapi.yaml

  - name: mocking
    config:
      api_specification_filename: expense-service/openapi.yaml
      random_delay: false
      max_delay_time: 1
      min_delay_time: 0
      include_base_url: false
```

Kong runs plugins in declaration order:
1. `ai-mcp-proxy` converts the MCP `tools/call` JSON into a REST request.
2. `mocking` intercepts that REST request and returns the spec example.
3. `ai-mcp-proxy` converts the REST response back into an MCP result.

The upstream URL (`http://mock-expense.internal`) is a placeholder that is
never resolved.

### Verify the MCP endpoints

Once the sync completes, confirm each route exposes the correct tools:

```terminal:execute
command: curl -s -X POST $PROXY/mcp/expense \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}' | jq '.result.tools[].name'
```

Expected output:
```
"approveExpense"
"rejectExpense"
"escalateExpense"
```

```terminal:execute
command: curl -s -X POST $PROXY/mcp/hr \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}' | jq '.result.tools[].name'
```

```terminal:execute
command: curl -s -X POST $PROXY/mcp/policy \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}' | jq '.result.tools[].name'
```

### Call a tool manually

Try calling the `getPolicy` tool directly to see what the Mocking plugin returns:

```terminal:execute
command: curl -s -X POST $PROXY/mcp/policy \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "id": 2,
    "params": {
      "name": "getPolicy",
      "arguments": {}
    }
  }' | jq '.result.content[0].text | fromjson'
```

You should see the policy rules from the spec example (auto-approve limit,
escalation threshold, restricted categories, etc.).

---

→ Continue to **Start the Agent**
