---
title: Semantic Cache
---

## Step 4 — Cache Semantically Similar Requests

The agent fetches company policy and reasons about similar expense types on
almost every run. Semantic caching lets Kong return a cached LLM response
when an incoming prompt is semantically close to one it has already answered
— cutting both latency and cost.

### Add the AI Semantic Cache plugin

In Konnect, navigate to the `llm-proxy` route and go to **Plugins → Add
Plugin → AI Semantic Cache**.

| Field | Value |
|-------|-------|
| Embeddings provider | `openai` |
| Embeddings model | `text-embedding-3-small` |
| Similarity threshold | `0.95` |
| Cache TTL | `300` (5 minutes) |

Click **Save**.

### Warm the cache

Run a first expense request in the **Expense Agent** tab to populate the
cache:

> *Alice (emp-001) wants to expense $150 for a team lunch.*

### Trigger a cache hit

Run a semantically similar request:

> *Alice (emp-001) is submitting $120 for a lunch with the team.*

Open **Konnect Analytics** and look at the `/llm` route row. If the cache
was hit, the response headers will include `X-Cache-Status: Hit` and the
latency will be significantly lower than the first run.

### Why this matters

LLM calls typically take 1–3 seconds. Cache hits return in under 100ms.
For a workshop agent that processes many similar expense types, even a 0.95
similarity threshold can serve a large fraction of requests from cache —
reducing both spend and response time without any change to the agent.

---

→ Continue to **Observe the Full Path**
