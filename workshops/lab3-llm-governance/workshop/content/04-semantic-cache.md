---
title: Semantic Cache
---

## Step 4 — Cache Semantically Similar Requests

The agent fetches company policy and reasons about similar expense types on
almost every run. Semantic caching lets Kong return a cached LLM response
when an incoming prompt is semantically close to one it has already answered
— cutting both latency and cost.

### Navigate to Semantic Caching

In Konnect, open your **AI Gateway** and click **Semantic caching** in the
left navigation. Click **+ Configure semantic caching**.

![Semantic caching empty state — click Configure semantic caching]({{< baseurl >}}/images/410-ai-manager-semantic-caching.png)

### Configure the vector database

In the first section, set:

| Field | Value |
|-------|-------|
| **Choose Vector Database Driver** | `redis` |
| **VectorDB Dimensions** | `3072` |
| **Caching Similarity Threshold** | `0.1` |
| **Choose VectorDB Distance Metric** | `cosine` |

Under **Configure Redis Vector**, set:

| Field | Value |
|-------|-------|
| **Host** | `{vault://ai/redis-host}` |
| **Port** | `{vault://ai/redis-port}` |
| **Username** | `{vault://ai/redis-username}` |
| **Password** | `{vault://ai/redis-password}` |

![Configure Redis Vector — host, port, username, and password set via vault references]({{< baseurl >}}/images/411-semantic-caching-vectordb-config.png)

> The Redis credentials are pulled from the Konnect Vault you configured at
> the start of the workshop — students never handle the raw values.

### Configure Embeddings

In the **Embeddings** section, set:

| Field | Value |
|-------|-------|
| **LLM Provider** | `OpenAI` |
| **Model Name** | `text-embedding-3-large` |
| **API key** | `{vault://ai/llm-api-key-openai}` |

![Embeddings section — OpenAI provider, text-embedding-3-large model, API key from vault]({{< baseurl >}}/images/412-semantic-caching-embeddings-config.png)

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
For a workshop agent that processes many similar expense types, even a 0.1
similarity threshold with cosine distance can serve a large fraction of
requests from cache — reducing both spend and response time without any
change to the agent.

---

→ Continue to **Observe the Full Path**
