---
title: LLM Failover
---

## Step 3 — Multi-Provider Failover

If your primary LLM provider goes down, your agent stops working. Kong's AI
Proxy plugin supports a `targets` list — it will try each provider in order
and fall through on failure.

### Update the AI Proxy plugin

Edit the **AI Proxy** plugin on `llm-proxy` to add a fallback target:

```yaml
config:
  targets:
    - route_type: llm/v1/chat
      auth:
        header_name: Authorization
        header_value: "Bearer $(llm_api_key_openai)"
      model:
        provider: openai
        name: gpt-4o-mini
  fallback_models:
    - route_type: llm/v1/chat
      auth:
        header_name: x-api-key
        header_value: "$(llm_api_key_anthropic)"
      model:
        provider: anthropic
        name: claude-haiku-4-5-20251001
```

### Simulate a provider failure

Stop traffic to OpenAI by configuring an invalid upstream (simulating an
outage):

In the Konnect UI, temporarily change the `llm-openai` service upstream
URL to `https://api.openai.invalid`.

Run the agent:

```bash
npm run dev -- "Alice (emp-001) wants to expense \$150 for a team lunch"
```

The agent should still complete — Kong automatically fell back to Anthropic.
In the Konnect Analytics logs you will see the OpenAI request fail with a
connection error followed immediately by a successful Anthropic call.

### Restore the primary

Change the upstream back to `https://api.openai.com`.

### Key insight

The agent has no knowledge of which LLM it's talking to. It sends the same
request to `$PROXY/llm` every time — Kong decides which provider handles it,
and retries transparently.

---

→ Continue to **Guardrails**
