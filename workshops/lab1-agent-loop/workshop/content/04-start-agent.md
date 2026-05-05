---
title: Open the Agent Dashboard
---

## Step 3 — Open the Agent Dashboard

The Expense Agent is already running as a containerised app inside your
Educates session. Click the **Expense Agent** tab at the top of this window
to open the UI.

### Configure the agent

The sidebar has two sections: **Gateway** and **LLM**.

**Gateway section:**

| Field | Value |
|-------|-------|
| Proxy URL | Paste the value of `$PROXY` from your terminal (run `echo $PROXY` to see it) |
| Agent API Key | Leave empty for Lab 1 — this field is used in Lab 2 |

**LLM section:**

| Field | Value |
|-------|-------|
| OpenAI API Key | Your personal OpenAI key (`sk-…`) |
| LLM Proxy | Leave empty — the agent calls OpenAI directly in Labs 1–2 |
| Model | Leave empty to use the default (`gpt-4o-mini`) |

Once filled in, click **Save Config**. The values are stored in browser
`localStorage` so you will not need to re-enter them if you reload the page.

### What the agent does with this config

Open `agent/src/agent.ts` in the editor tab and read through it:

```terminal:execute
command: cat agent/src/agent.ts
```

Notice three things:

1. **`tools` array** — three `mcp()` entries, each pointing at `$PROXY/mcp/*`.
   The agent has no knowledge of the upstream REST APIs or the Mocking plugin;
   it only sees the tools discovered at those URLs.

2. **`llm.baseURL`** — the LLM Proxy field from the sidebar. In Labs 1–2 this
   goes directly to OpenAI. In Lab 3 you will change this single value to route
   all LLM traffic through the Kong AI Gateway.

3. **`instructions`** — the system prompt that describes the agent's reasoning
   process: retrieve policy → look up employee → evaluate → act.

---

→ Continue to **Your First Decisions**
