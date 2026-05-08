---
title: Observe Governance
---

### Step 3 — See What Kong Captured

Run a couple more expenses — try **✈️ Conference trip · $2,500** and
**📎 Office supplies · $89** — then switch back to Konnect.

---

### 1 · Check the AI Gateway Analytics

In Konnect navigate to **AI Gateway → LLM Gateway → Analytics** in the
left sidebar.

You will see aggregate metrics for every LLM call the agent made:

![Konnect AI Gateway Analytics — requests, tokens, latency]({{< baseurl >}}/images/10-back-to-konnect-check-analytics.png)

| Metric | What it tells you |
|--------|-------------------|
| **Requests** | Total LLM calls — one per reasoning step, not per expense run |
| **Tokens** | Cumulative token usage across all calls |
| **Error Rate** | Any 4xx/5xx responses from OpenAI |
| **Average Latency** | End-to-end time Kong waited for the LLM response |

---

### 2 · Open the pre-built AI Gateway dashboard

Navigate to **Observability → Dashboards**. You will find an
**AI Gateway Analytics Dashboard** already created for your environment.
Click on it to open it.

![Observability Dashboards — select the pre-built AI Gateway Analytics Dashboard]({{< baseurl >}}/images/11-o11y-select-preconfigured-dashboard.png)

---

### 3 · Read the dashboard

The dashboard shows live data from the expenses you just ran:

![AI Gateway Dashboard — model usage, provider, status codes, token chart]({{< baseurl >}}/images/13-ai-gateway-dashboard-data.png)

| Panel | What it shows |
|-------|---------------|
| **GenAI model usage count** | Requests by model — you should see `gpt-4o-mini` |
| **GenAI provider usage count** | Requests by provider — `openai` |
| **AI status codes** | 2xx = all successful; 4xx/5xx errors appear here |
| **Token usage by provider** | Token consumption over time — spot runaway agent loops immediately |
| **AI security report** | Prompt injection attempts blocked by guardrails (empty for now — Lab 3 adds them) |

---

### What this means

You governed the LLM without changing a single line of agent code:

- Every reasoning step is a logged, measurable Kong request
- Token usage is visible in aggregate and over time
- Any model, provider, or error anomaly shows up on the dashboard
- The OpenAI key is in the vault — not in the agent, not in any config file

This is the baseline. Labs 2 and 3 add authentication on tool routes,
rate limits, prompt guardrails, and semantic caching — all as plugins
on top of what you built today.

---

→ Continue to **Summary**
