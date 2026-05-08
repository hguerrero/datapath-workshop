---
title: Connect the Agent
---

### Step 2 — To the AI Gateway

The gateway is live. Now point the agent at it with two field values.

### Open the Expense Agent dashboard

Click the **Expense Agent** tab at the top of this window.

```dashboard:open-dashboard
name: Expense Agent
```

### Configure the agent

Fill in the sidebar fields exactly as shown below, then click **Save Config**.

| Section | Field | Value |
|---------|-------|-------|
| Gateway | Proxy URL | Leave empty — not used now |
| Gateway | Agent API Key | Leave empty — not used until Lab 2 |
| LLM | OpenAI API Key | **Leave empty** — Kong injects the key; the agent does not need it |
| LLM | LLM Proxy | Same base URL with `/llm` appended (e.g. `https://xxxx.us.serverless.gateways.konghq.com/llm`) |
| LLM | Model | Leave empty to use the default (`gpt-4o-mini`) |

![Agent UI — Proxy URL and LLM Proxy filled in, OpenAI key left empty]({{< baseurl >}}/images/08-add-llm-proxy-url-to-agent.png)

> **Why is the OpenAI key field empty?**  
> The `ai-proxy` plugin reads your key from the Konnect vault and injects
> it into every outbound request. The agent process, its config files,
> and its container image never hold the credential.

### Run your first governed expense

Click the **🍱 Team lunch · $150** chip, then press **▶ Run Agent**.

Wait for the status to show **Done.** — the result card should read
**APPROVED** with the agent's reasoning.

![Agent result — APPROVED with reasoning]({{< baseurl >}}/images/09-run-the-agent-with-an-expense.png)

The decision is identical to a direct OpenAI call. What has changed is
that Kong now owns the credential and logged every step of the reasoning.

---

→ Continue to **Observe Governance**
