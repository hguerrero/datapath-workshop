---
title: LLM Failover
---

## Step 2 — Multi-Provider Failover

If your primary LLM provider goes down, your agent stops working. Kong's AI
Proxy plugin supports a `fallback_models` list — it will try each provider
in order and fall through on failure.

### Update the AI Proxy plugin

In Konnect, navigate to the `llm-proxy` route and open the **AI Proxy**
plugin. Edit the configuration to add a fallback target:

| Section | Field | Value |
|---------|-------|-------|
| Primary target | Provider | `openai` |
| Primary target | Model | `gpt-4o-mini` |
| Primary target | Auth header value | `Bearer {env://OPENAI_API_KEY}` |
| Fallback model | Provider | `anthropic` |
| Fallback model | Model | `claude-haiku-4-5-20251001` |
| Fallback model | Auth header value | `{env://ANTHROPIC_API_KEY}` |

Click **Save**.

### Simulate a provider failure

In Konnect, temporarily edit the `llm-openai` gateway service and change
its upstream URL from `https://api.openai.com` to
`https://api.openai.invalid` to simulate an outage.

Run an expense in the **Expense Agent** tab:

> *Alice (emp-001) is submitting $150 for a team lunch.*

The agent should still complete successfully — Kong automatically fell back
to Anthropic. In Konnect Analytics you will see the OpenAI request fail
followed immediately by a successful Anthropic call.

### Restore the primary

Change the gateway service upstream URL back to `https://api.openai.com`.

### Key insight

The agent has no knowledge of which LLM it's talking to. It sends the same
request to `/llm` every time — Kong decides which provider handles it and
retries transparently. Swap providers, add fallbacks, or reroute traffic
entirely without touching the agent.

---

→ Continue to **Prompt Guardrails**
