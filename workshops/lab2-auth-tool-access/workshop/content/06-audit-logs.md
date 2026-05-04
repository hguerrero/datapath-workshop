---
title: Audit Logs
---

## Step 6 — Observe the Audit Trail

Open **Konnect Analytics → Requests** and filter to the last 15 minutes.

For each completed agent run you should see a group of 4–6 requests, all
attributed to `expense-agent`. Each row includes:

- **Timestamp** — exact time of the tool call
- **Consumer** — `expense-agent`
- **Route** — `/mcp/expense`, `/mcp/hr`, or `/mcp/policy`
- **Status** — 200 (success) or 403 (ACL denied)
- **Latency** — time in Kong + upstream service

### Export as CSV (optional)

In Konnect Analytics, use the export button to download a CSV of the last
30 minutes. This is what a compliance audit trail would look like in
production — every agent action, timestamped, attributed to a named identity,
with the upstream that was touched.

### Structured logging with the File Log plugin

For a persistent log, add the **File Log** plugin to any route:

| Field | Value |
|-------|-------|
| Path | `/tmp/kong-agent-audit.log` |

After running the agent once more:

```bash
cat /tmp/kong-agent-audit.log | jq '.consumer.username, .request.uri, .response.status'
```

Each line is a structured JSON log entry.

---

→ Continue to **Summary**
