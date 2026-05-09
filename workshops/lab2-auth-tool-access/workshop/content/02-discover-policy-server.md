---
title: Discover the Policy Server
---

## Step 2 — Explore the Policy MCP Server

Your gateway already has the MCP tool routes pre-configured — including a
Policy MCP server at `/mcp/policy`. You can explore it right now using
**MCP Inspector** with the same Proxy URL you used in Lab 1.

### Open MCP Inspector

```dashboard:open-dashboard
name: MCP Inspector
```

### Connect to the policy server

In MCP Inspector, configure the connection using your gateway's Proxy URL
(the same one from Lab 1):

| Field | Value |
|-------|-------|
| Transport Type | Streamable HTTP |
| URL | `<your-proxy-url>/mcp/policy` |
| Connection Type | Direct |

Click **Connect** and wait for the **Connected** status to turn green.

### List the available tools

Click **Tools** in the right panel, then click **List Tools**.

![MCP Inspector connected to /mcp/policy showing the getPolicy tool]({{< baseurl >}}/images/204-mcp-policy-with-mcp-inspector.png)

You will see one tool:

| Tool | Description |
|------|-------------|
| `getPolicy` | Returns the company-wide policy rules |

### What `getPolicy` returns

Click on `getPolicy` and then click **Run Tool**. The response includes
your company's expense rules — the $200 auto-approval limit, receipt
requirements, and category restrictions that the agent was missing.

### What this means

You connected with **no credentials at all** — no API key, no token.
Anyone who knows your Proxy URL can call `getPolicy` directly, bypassing
the agent entirely.

In Step 5 you will add Key Authentication to this route. For now, let's
connect the agent and see the policy kick in.

---

→ Continue to **Connect the Agent**
