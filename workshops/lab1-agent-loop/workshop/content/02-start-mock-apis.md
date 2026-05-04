---
title: Explore the Mock API Specs
---

## Step 1 — Explore the Mock API Specs

The workshop uses three OpenAPI specs as stand-ins for real back-end systems.
There are **no running services** — Kong's Mocking plugin reads the `example`
fields directly from each spec and returns them as HTTP responses.

| Spec | Path | What it describes |
|------|------|-------------------|
| `expense-service/openapi.yaml` | `mock-apis/expense-service/` | Approve / reject / escalate decisions |
| `hr-service/openapi.yaml` | `mock-apis/hr-service/` | Employee details and spending limits |
| `policy-service/openapi.yaml` | `mock-apis/policy-service/` | Policy rules and expense evaluation |

### Read the expense spec

Take a moment to look at the expense service spec:

```terminal:execute
command: cat mock-apis/expense-service/openapi.yaml
```

Notice three things:

1. **Three action endpoints** — `/approve`, `/reject`, `/escalate`.
   Each `operationId` becomes the MCP tool name the agent will call.

2. **`example` in each 200 response** — this is what Kong's Mocking plugin
   returns. No upstream logic is needed; the example payload is the response.

3. **No server block** — the spec describes the shape of the API, not where
   it runs. Kong handles routing.

### Serve the specs locally

Kong reads the spec files over HTTP when it bootstraps the AI MCP Proxy plugin.
Start a local file server from the repo root:

```terminal:execute
command: python3 -m http.server 8888 --directory mock-apis &
echo "Spec server PID: $!"
```

Set the environment variable used by decK:

```terminal:execute
command: export SPEC_BASE_URL=http://localhost:8888
echo "SPEC_BASE_URL=$SPEC_BASE_URL"
```

> **Alternative:** After publishing the repo you can use the raw GitHub URL
> instead:
> ```
> export SPEC_BASE_URL=https://raw.githubusercontent.com/Kong/kong-data-path-workshop/main/mock-apis
> ```
> This is useful in production instructor-led environments where students have
> no local server.

### Verify a spec is reachable

```terminal:execute
command: curl -s $SPEC_BASE_URL/expense-service/openapi.yaml | head -20
```

You should see the first lines of the OpenAPI YAML. If you get a connection
error, check that the file server is still running.

---

→ Continue to **Expose APIs as MCP Tools**
