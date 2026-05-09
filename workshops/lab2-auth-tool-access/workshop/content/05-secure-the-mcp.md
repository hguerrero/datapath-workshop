---
title: Secure the MCP Server
---

## Step 5 — Lock Down the Policy MCP Server

In Step 2 you connected to `/mcp/policy` with no credentials. That means
anyone who knows your Proxy URL can call `getPolicy` directly — no agent
required. Let's fix that.

### Add Key Authentication to the MCP policy route

In Konnect, navigate to your gateway and open **Routes**.

Find the `mcp-policy` route (path: `/mcp/policy`) and click on it.

Go to **Plugins → Add Plugin → Key Authentication**.

Leave all settings at their defaults — the plugin will require an `apikey`
header on every request to this route.

Click **Save**.

### Verify the route is now protected

Switch back to **MCP Inspector** and click **Reconnect** using the same URL
as before (`<your-proxy-url>/mcp/policy`).

The connection should now fail with `401 Unauthorized` — the route is
protected.

### Create a consumer and issue an API key

In your gateway in Konnect, navigate to **Consumers → New Consumer**.

| Field | Value |
|-------|-------|
| Username | `expense-agent` |

Save the consumer. Then open it and go to **Credentials → Key Auth →
New Key Auth Credential**.

Konnect will generate an API key. Copy it.

### Update the agent

Switch to the **Expense Agent** tab and fill in the **Agent API Key
(Lab 2+)** field with the key you just generated. Click **Save Config**.

### Verify the agent still works

Run Alice's expense again:

> *Alice (emp-001) is submitting $250 for a team lunch.*

The result should still be **REJECTED** — the agent is now sending the API
key on every call to `/mcp/policy` and Kong is accepting it.

### Confirm unauthenticated access is blocked

Clear the **Agent API Key** field and run the same request. The agent's
call to `getPolicy` will return `401 Unauthorized` and it will fall back
to general reasoning — approving the expense like it did in Step 1.

Restore the key to confirm the rejection comes back.

### What Kong enforces now

| Check | Enforced by |
|-------|-------------|
| Request has a valid API key | Key Auth plugin on `/mcp/policy` |
| Key belongs to a known consumer | Kong consumer database |
| Consumer identity visible in analytics | Konnect Analytics |

Zero lines of agent code changed. The enforcement lives entirely in Kong.

---

→ Continue to **Summary**
