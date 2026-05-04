---
title: Semantic Cache
---

## Step 5 — Cache Semantically Similar Requests

The agent calls the policy service MCP tool to retrieve company policy on
almost every run. The policy rarely changes, but the agent re-fetches it from
the LLM context every time. Semantic caching lets Kong return a cached LLM
response when an incoming prompt is semantically similar to one it has
already answered.

### Add the AI Semantic Cache plugin

On the `llm-proxy` route, add **AI Semantic Cache**:

| Field | Value |
|-------|-------|
| Embeddings provider | `openai` |
| Embeddings model | `text-embedding-3-small` |
| Similarity threshold | `0.95` |
| Cache TTL | `300` (5 minutes) |

### Warm the cache

Run the agent once to populate the cache:

```bash
npm run dev -- "Alice (emp-001) wants to expense \$150 for a team lunch"
```

### Trigger a cache hit

Run a semantically similar expense (same category, similar amount):

```bash
npm run dev -- "Alice (emp-001) is submitting \$120 for a lunch with the team"
```

In Konnect Analytics, look at the LLM route row. The response headers will
include `X-Cache-Status: Hit` if the semantic cache served the response
without calling the LLM.

### Measure the latency difference

```bash
# Cache miss (first run)
time npm run dev -- "Alice (emp-001) wants to expense \$150 for a team lunch"

# Cache hit (second run)
time npm run dev -- "Alice (emp-001) is submitting \$140 for a lunch meeting"
```

Cache hits are typically 50–100ms vs 1–3s for a live LLM call.

---

→ Continue to **Observe the Full Path**
