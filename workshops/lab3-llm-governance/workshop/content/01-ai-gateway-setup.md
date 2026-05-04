---
title: AI Gateway Setup
---

## Step 1 — Route LLM Calls Through Kong

### Create the LLM route

In the Konnect UI, create a new Gateway Service:

| Field | Value |
|-------|-------|
| Name | `llm-openai` |
| Upstream URL | `https://api.openai.com` |

Add a Route:

| Field | Value |
|-------|-------|
| Name | `llm-proxy` |
| Paths | `/llm` |
| Strip path | `true` |

Add the **AI Proxy** plugin to the route:

| Field | Value |
|-------|-------|
| Provider | `openai` |
| Model | `gpt-4o-mini` |
| Auth → Header name | `Authorization` |
| Auth → Header value | `Bearer $(llm_api_key)` |

> **Security note:** The API key is stored in a Konnect Config Store entry,
> not in the route config directly. The `$(llm_api_key)` syntax is resolved
> by Kong at request time. Students do not need to handle the LLM API key
> themselves from Lab 3 onward — Kong holds it.

### Update the agent

In `agent/.env`:

```bash
LLM_PROXY=$LLM_PROXY
```

The `$LLM_PROXY` variable is already set in your Educates session. Paste
its value into your `.env` file:

```bash
echo "LLM_PROXY=$LLM_PROXY" >> agent/.env
```

### Test the route directly

```bash
curl -s -X POST $PROXY/llm/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "apikey: $AGENT_API_KEY" \
  -d '{
    "model": "gpt-4o-mini",
    "messages": [{"role": "user", "content": "Say: Kong AI Gateway is working."}]
  }' | jq '.choices[0].message.content'
```

### Run the agent

```bash
cd agent && npm run dev
```

The agent should run exactly as before. Now open Konnect Analytics — you
will see **both** the MCP tool calls and the LLM call in the same log view.
The full data path is visible in one place for the first time.

---

→ Continue to **Rate Limiting**
