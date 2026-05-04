---
title: Rate Limiting
---

## Step 2 — Control LLM Spend

LLM calls cost money. Without rate limiting, a runaway agent (or a loop bug)
can exhaust your budget in minutes.

### Add the AI Rate Limiting Advanced plugin

On the `llm-proxy` route, add **AI Rate Limiting Advanced**:

| Field | Value |
|-------|-------|
| Limit by | `consumer` |
| Window size | `minute` |
| Request limit | `10` |
| Token limit (prompt) | `5000` |
| Token limit (completion) | `2000` |

This applies per-consumer limits: the `expense-agent` consumer can make at
most 10 LLM calls per minute and consume at most 5000 prompt tokens.

### Test the limit

Run several expenses quickly:

```bash
for i in $(seq 1 12); do
  npm run dev -- "Alice (emp-001) wants to expense \$50 for coffee"
done
```

After 10 runs you should see:

```
429 Too Many Requests
```

In the Konnect Analytics token usage panel, observe the running token count
for the `expense-agent` consumer.

### Why this matters

A single misconfigured agent prompt can send megabytes of context per call.
Token-based limits give you cost control that request-count limits alone
can't provide. Kong counts tokens at the gateway — no changes to the agent
or the LLM provider needed.

---

→ Continue to **Failover**
