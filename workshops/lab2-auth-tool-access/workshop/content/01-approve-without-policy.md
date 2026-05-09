---
title: Approve Without Policy
---

## Step 1 — See the Agent Approve Without Any Policy

Open the **Expense Agent** tab in your browser.

```dashboard:open-dashboard
name: Expense Agent
```

> **Before you run the agent**, confirm the **LLM Proxy** field is set to
> your gateway's proxy URL followed by `/llm` — for example:
> `https://<id>.us.serverless.gateways.konggateway.com/llm`
>
> This is the same value you copied from Konnect in Lab 1. If the field is
> empty, go to Konnect → your gateway → Overview and copy the Proxy URL,
> then append `/llm` before saving.

### Submit Alice's expense

In the **Expense request** field, type or click the pre-loaded example:

> *Alice (emp-001) is submitting $250 for a team lunch.*

Leave the **Proxy URL** field empty for now and click **Run Agent**.

![Agent approves Alice's $250 expense with no policy context]({{< baseurl >}}/images/203-test-without-mcp.png)

The agent responds: **APPROVED**.

The reasoning sounds sensible — *"$250 is within typical lunch budget limits
for a team and does not fall into any prohibited categories."*

### The problem

The agent is reasoning from general world knowledge. It has no idea that your
company's policy says:

- Expenses **over $200** require a receipt
- Expenses **over $200** that aren't travel, conference, or equipment are
  rejected outright at the auto-approval stage

$250 for a team lunch should be **REJECTED** — but the agent doesn't know
that yet.

The fix isn't to retrain the model or change the prompt. It's to give the
agent access to a tool that returns your actual policy.

---

→ Continue to **Discover the Policy Server**
