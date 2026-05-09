---
title: Secure the MCP Server
---

## Step 5 — Secure the MCP Server with OAuth2

In Step 2 you connected to `/mcp/policy` with no credentials. Now you will
add the **AI MCP OAuth2** plugin to that route. The plugin validates Bearer
tokens against a Kong Identity authorization server that was
pre-provisioned for your student environment.

### Find your authorization server endpoints

In Konnect, navigate to **Identity** in the left sidebar and click on your
authorization server — for example `student-01-auth-server`.

![Kong Identity auth server overview showing Issuer URL and Metadata URL]({{< baseurl >}}/images/206-auth-server-openid-config.png)

Note the **Issuer URL** and **Metadata URL** displayed on this page. The
Issuer URL is what you will enter in the plugin. The Metadata URL points to
the OpenID Connect discovery document — click it to see all available
endpoints.

![Well-known OpenID Connect configuration listing all endpoints]({{< baseurl >}}/images/206-well-known-endpoints.png)

From the discovery document, note down:

| Endpoint | JSON key |
|----------|----------|
| Token endpoint | `token_endpoint` |
| Introspection endpoint | `introspection_endpoint` |

You will also need the **Client ID** and **Client Secret** for your
application (`student-01-application`). Your instructor will provide these,
or you can find them in your Terraform outputs.

### Add the AI MCP OAuth2 plugin to the policy route

In Konnect, navigate to **API Gateway → your gateway → Routes** and click
on the `student-XX-policy-mcp` route.

Open the **Plugins** tab and click **+ New plugin**.

![Policy MCP route Plugins tab with existing AI MCP Proxy plugin]({{< baseurl >}}/images/207-policy-mcp-route-new-plugin.png)

In the plugin catalog, search for **oauth2** and click **Configure** on
**AI MCP OAuth2**.

![Plugin catalog filtered to show AI MCP OAuth2]({{< baseurl >}}/images/207-mcp-oauth2-plugin.png)

Fill in the plugin configuration:

| Field | Value |
|-------|-------|
| `resource` | `<your-proxy-url>/mcp/policy` |
| `authorization_servers` | Your Issuer URL from Kong Identity |
| `introspection_endpoint` | Your introspection endpoint from the discovery doc |
| `client_id` | Your application's Client ID |
| `client_secret` | Your application's Client Secret |
| `insecure_relaxed_audience_validation` | `true` |

> **Why `insecure_relaxed_audience_validation`?** The MCP OAuth2 spec
> requires the token's `aud` claim to match the resource URL (RFC 8707).
> Kong Identity does not yet include this claim, so relaxing audience
> validation lets the plugin accept the token regardless.

Click **Save**.

### Verify the route is protected

Switch to **MCP Inspector** and click **Connect** using your proxy URL
with no authentication set.

![MCP Inspector connection fails with 401 after plugin is added]({{< baseurl >}}/images/208-test-inspector-without-auth-and-fail.png)

The connection fails — the route now requires a valid Bearer token.

### Get an access token

From the **Terminal** tab, request a token using the client credentials
grant:

```bash
curl -s -X POST $TOKEN_ENDPOINT \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" | jq -r '.access_token'
```

Copy the token and save it:

```bash
export ACCESS_TOKEN=<paste-token-here>
```

### Connect MCP Inspector with the token

In **MCP Inspector**, expand the **Authentication** section. Enable the
**Authorization** header toggle and enter:

```
Bearer <ACCESS_TOKEN>
```

Click **Reconnect**.

![MCP Inspector authenticated with Bearer token — getPolicy tool visible]({{< baseurl >}}/images/209-add-authorization-token-to-mcp-inspector.png)

The connection succeeds and `getPolicy` is available again — this time as
an authenticated client.

### Update the agent

Switch to the **Expense Agent** tab and paste the access token into the
**Agent API Key (Lab 2+)** field. Click **Save Config**.

Run Alice's expense request:

> *Alice (emp-001) is submitting $250 for a team lunch.*

![Agent with Bearer token — expense correctly rejected by policy]({{< baseurl >}}/images/210-agent-with-key-successfully-rejects-250-expense.png)

The result is **REJECTED** — the agent is presenting the Bearer token on
every call to `/mcp/policy`, Kong is validating it against Kong Identity,
and the policy rules are being applied.

### Confirm unauthenticated access is blocked

Clear the **Agent API Key** field and run the same request.

![Agent without token — 401 Authorization Required error]({{< baseurl >}}/images/210-agent-without-key-fails-with-401-authorization-required.png)

The agent receives a `401 Authorization Required` error on its first MCP
call and cannot proceed. Restore the token to confirm the rejection returns.

### What Kong enforces now

| Check | Enforced by |
|-------|-------------|
| Request carries a Bearer token | AI MCP OAuth2 plugin |
| Token is valid and not expired | Introspection against Kong Identity |
| Token stripped before reaching upstream | Plugin default (prevents confused deputy attacks) |

Zero lines of agent code changed. The enforcement lives entirely in Kong,
backed by a real OAuth2 authorization server.

---

→ Continue to **Summary**
