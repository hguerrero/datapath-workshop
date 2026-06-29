---
title: Control Spend
---

## Step 1 — Control LLM Spend

LLM calls cost money. Without rate limiting, a runaway agent (or a loop bug)
can exhaust your budget in minutes. The **AI Rate Limiting Advanced** plugin
counts tokens at the gateway — no changes to the agent or the LLM provider —
and enforces limits per provider, per window.

### Navigate to your control plane

Open **Konnect** and go to **Gateway Manager**.

```dashboard:open-url
url: https://cloud.konghq.com/login/{{< param training_portal >}}
```

Click on your `student-XX-cp` control plane.

![Gateway Manager showing student control planes — click your student-XX-cp]({{< baseurl >}}/images/301-navigate-to-gateway-control-plane.png)

### Find the /llm route

In the left navigation click **Routes**. Find the route with path `/llm` — it
will be named `AIManagerModelRoute_...` and was created automatically when you
configured the AI Proxy in Lab 1.

![Routes list — click the route with path /llm]({{< baseurl >}}/images/302-select-llm-route.png)

### Add a plugin

Click on the `/llm` route to open its detail page. Go to the **Plugins** tab
and click **+ New plugin**.

![Route Plugins tab — click + New plugin]({{< baseurl >}}/images/303-route-plugins-new-plugin.png)

In the plugin catalog, type **ai rate** in the search box. Click **Configure**
on the **AI Rate Limiting Advanced** plugin.

![Plugin catalog filtered to AI Rate Limiting Advanced — click Configure]({{< baseurl >}}/images/304-ai-rate-limiting.png)

### Configure the Policy

The plugin enforces limits through **Policies** — each policy is a token
bucket with a **Tokens Count Strategy** and one or more window-based limits.

Click **+ New Item** under **Policies** to add a policy. With the policy added, set two window limits within it:

**Limit 1 — per-minute burst**

Click **+ New Item** under **Limits** and set:

| Field | Value |
|-------|-------|
| **Limit** | `1000` |
| **Tokens Count Strategy** | `total_tokens` |
| **Window Size** | `60` |

**Limit 2 — per-hour sustained**

Click **+ New Item** under **Limits** again and set:

| Field | Value |
|-------|-------|
| **Limit** | `10000` |
| **Tokens Count Strategy** | `total_tokens` |
| **Window Size** | `3600` |

![Policies section showing the two window limits — 1000/60s and 10000/3600s]({{< baseurl >}}/images/305-ai-rate-limiting-policies-details1.png)

> **total_tokens** counts both prompt and completion tokens together. This is
> the most conservative strategy and gives you the tightest cost control —
> a single large response counts against the same budget as many small requests.

### Configure the Match (partition by provider)

Scroll down to the **Match** section. This tells the plugin how to bucket
counters — here you want separate counters per LLM provider so that a spike
on one provider doesn't incorrectly consume another provider's budget.

Enable **Partition By** and set:

| Field | Value |
|-------|-------|
| **Partition By → Type** | `provider` |
| **Partition By → Values** | `openai` |

![Match section — Partition By provider: openai]({{< baseurl >}}/images/305-ai-rate-limiting-policies-details2.png)

### Configure the Window Type

Back in the top-level plugin config, set:

| Field | Value |
|-------|-------|
| **Window Type** | `sliding` |

> **Sliding window** means the 60-second or 3600-second window rolls with time
> rather than resetting on a fixed clock boundary — preventing burst abuse at
> window edges.

Click **Save**.

### Test the limit

Open the **Expense Agent** tab and run several expenses in quick succession
using the pre-loaded examples. After the token budget is exhausted within the
window the agent will return a **Server error: 429 status code** — the gateway
blocks the request before it ever reaches OpenAI.

![Expense Agent showing Server error: 429 status code after token limit is hit]({{< baseurl >}}/images/306-expense-agent-http-429.png)

Notice that the error appears immediately with no LLM response body — Kong
rejected the call at the gateway layer, so no tokens were charged to your
OpenAI account for that request.

In Konnect **Analytics**, open the token usage panel for the `/llm` route to
observe the running token count per provider accumulating in real time.

---

→ Continue to **LLM Failover**
