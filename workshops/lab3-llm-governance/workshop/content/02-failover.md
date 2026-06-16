---
title: LLM Failover
---

## Step 2 — Multi-Provider Load Balancing

Relying on a single LLM provider is a single point of failure. Kong's
**AI Gateway** manages multi-provider routing through its **Load balancing**
feature — you register multiple providers and the gateway distributes traffic
between them. When one provider is unavailable, the others continue serving
requests without any change to your agent.

### Navigate to the LLM Gateway

In Konnect, click **AI Gateway** in the left navigation. You will see the
**LLM Gateway - student-xx** card — this is the AI Gateway created in Lab 1, currently
serving OpenAI traffic through your `student-XX-cp` control plane.

![AI Gateway showing the LLM Gateway card with OpenAI and live token metrics]({{< baseurl >}}/images/311-ai-gateway-llm-gateway.png)

Click on the **LLM Gateway - student-xx** card, then click **Load balancing** in the
left sub-navigation.

The load balancing page shows your existing OpenAI/gpt-4o-mini provider with
algorithm **Round robin / Weighted**. Traffic is currently 100% OpenAI.

![Load balancing page showing OpenAI/gpt-4o-mini as the sole provider]({{< baseurl >}}/images/312-llm-gateway-load-balancing.png)

### Add Anthropic as a second provider

Click **+ Connect LLM**.

#### General information

| Field | Value |
|-------|-------|
| **LLM Provider** | `Anthropic` |
| **Route type** | `llm/v1/chat` |
| **Models** | All models |
| **Anthropic version** | `2023-06-01` |

![Connect LLM form — Anthropic provider, llm/v1/chat route, version 2023-06-01]({{< baseurl >}}/images/313-load-balancing-provider-details.png)

#### Authentication

Under **Authentication from gateway to LLM**, select
**Provided by the AI gateway**, then click **pick a secret from vaults**
next to the API key field.

In the **Look up key in vault** dialog:

| Field | Value |
|-------|-------|
| **Vault** | Select the `ai-` vault from the dropdown |
| **Secret ID** | `llm-api-key-anthropic` |

Click **Use key**, then **Save**.

![Vault secret picker — selecting llm-api-key-anthropic from the AI vault]({{< baseurl >}}/images/313-load-balancing-api-key-vault.png)

The load balancing page now shows both OpenAI and Anthropic. The gateway will
distribute requests between them using round-robin — no changes to your agent
or the `/llm` route.

### Test multi-provider routing

Open the **Expense Agent** tab. In the **Model** field, enter
`claude-haiku-4-5-20251001` and run the Alice team lunch example.

Because the load balancer uses round-robin, you will observe two possible
outcomes depending on which provider the gateway selects:

**When the gateway routes to Anthropic** — the request succeeds. Anthropic
handles `claude-haiku-4-5-20251001` natively and returns an approval decision.

![Expense Agent — APPROVED response from claude-haiku-4-5-20251001 via Anthropic]({{< baseurl >}}/images/314-expense-agent-load-balanced-anthropic-haiku-model.png)

**When the gateway routes to OpenAI** — the request fails with a 400 error:
*"cannot use own model — must be: gpt-4o-mini"*. OpenAI doesn't recognise a
Claude model name and the gateway enforces the configured model for that
provider.

![Expense Agent — 400 error when round-robin selects OpenAI for a claude model request]({{< baseurl >}}/images/314-expense-agent-load-balancing-openai-own-model-haiku.png)

> **What this shows:**
> Model names are provider-specific. When using load balancing across
> providers, the gateway controls which model each provider uses based on its
> own configuration — the model field in the agent is a hint, not a guarantee.
> For production use, leave the model field empty and let the gateway's load
> balancing config determine the model per provider.

### Key insight

The agent sends every request to the same `/llm` endpoint. The AI Gateway
decides which provider handles each call. Add providers, adjust weights, or
remove a provider entirely — the agent never changes. This is the same
outside-in governance principle: control at the gateway layer, not inside
the application.

---

→ Continue to **Prompt Guardrails**
