---
title: Verify the MCP Tools
---

## Step 2 — Verify the MCP Tools

The Terraform provisioning already applied the Kong configuration. Before
running the agent, confirm that all three MCP routes are serving the correct
tools.

### List tools on each route

```terminal:execute
command: curl -s -X POST $PROXY/mcp/expense \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}' | jq '.result.tools[].name'
```

Expected:
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

Expected:
```
"getEmployee"
```

```terminal:execute
command: curl -s -X POST $PROXY/mcp/policy \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}' | jq '.result.tools[].name'
```

Expected:
```
"getPolicy"
"evaluateExpense"
```

> If any of these return a 404 or an empty tools list, let your instructor
> know — the Terraform apply may not have completed yet.

### Call a tool manually

Try calling `getPolicy` directly to see the raw payload the Mocking plugin
returns. This is exactly what the agent will receive on its first tool call:

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

Read through the output. Note the `autoApproveLimit`, `escalationThreshold`,
and `restrictedCategories` values — these are the rules the agent will use
when it evaluates expenses in the next step.

### Explore with MCP Inspector

Open the **MCP Inspector** dashboard tab and connect it to `$PROXY/mcp/policy`.
You can browse all available tools and call them interactively — a useful
debugging tool in later labs when you add authentication.

---

→ Continue to **Open the Agent Dashboard**
