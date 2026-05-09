---
title: Control Spend
---

## Step 1 — Control LLM Spend

LLM calls cost money. Without rate limiting, a runaway agent (or a loop bug)
can exhaust your budget in minutes.

### Add the AI Rate Limiting Advanced plugin

In Konnect, navigate to your gateway, open **Routes**, and click on the
`llm-proxy` route (path: `/llm`).

Go to **Plugins → Add Plugin** and select **AI Rate Limiting Advanced**.

| Field | Value |
|-------|-------|
| Limit by | `consumer` |
| Window size | `minute` |
| Request limit | `10` |
| Token limit (prompt) | `5000` |
| Token limit (completion) | `2000` |

Click **Save**.

This applies per-consumer limits: the `expense-agent` consumer can make at
most 10 LLM calls per minute and consume at most 5000 prompt tokens.

### Test the limit

Open the **Expense Agent** tab and run several expenses in quick succession
using the pre-loaded examples. After 10 runs within a minute you should see
the agent return a `429 Too Many Requests` error on the LLM call.

In Konnect Analytics, open the token usage panel for the `/llm` route and
observe the running token count attributed to your consumer.

### Why token limits matter

A single misconfigured agent prompt can send megabytes of context per call.
Request-count limits alone miss this — a single request with a huge context
window can cost as much as dozens of normal ones. Token-based limits give
you cost control at the right granularity. Kong counts tokens at the
gateway, with no changes to the agent or the LLM provider needed.

---

→ Continue to **LLM Failover**
