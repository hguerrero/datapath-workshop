---
title: Add Key Authentication
---

## Step 2 — Lock Down the Tool Routes

Add the **Key Authentication** plugin globally so it applies to all three
MCP routes at once.

### Option A — Konnect UI

Navigate to **Plugins → Add Plugin → Key Authentication**.
Apply it at the **Gateway** level (not on a specific route) so it covers
all routes by default.

Leave all plugin settings at their defaults — the plugin will look for an
`apikey` header.

### Option B — decK

```bash
deck gateway sync decK/lab2-auth-tool-access/kong.yaml \
  --konnect-token $KONNECT_TOKEN \
  --konnect-control-plane-name $CP_NAME
```

### Verify authentication is enforced

```bash
curl -s -X POST $PROXY/mcp/expense \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}'
```

Expected response:

```json
{"message":"No API key found in request"}
```

HTTP status: `401 Unauthorized` ✓

Now verify the same call fails for all three routes:

```bash
for path in expense hr policy; do
  echo -n "/mcp/$path: "
  curl -s -o /dev/null -w "%{http_code}" -X POST $PROXY/mcp/$path \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"tools/list","id":1}'
  echo
done
```

All three should return `401`.

---

→ Continue to **Create a Consumer**
