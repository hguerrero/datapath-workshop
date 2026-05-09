---
title: Observe MCP Traffic
---

## Step 6 — Observe MCP Tool Usage

You've run several expense requests through the agent. Now let's look at the
traffic in Konnect — specifically the MCP tool calls — using the
**Agentic analytics dashboard**.

### Create the Agentic analytics dashboard

In Konnect, navigate to **Observability → Dashboards** and click
**+ New dashboard**.

In the **Create from template** dialog, scroll to the
**Agentic analytics dashboard** template.

![Create from template dialog showing the Agentic analytics dashboard option]({{< baseurl >}}/images/211-create-agentic-dashboard-from-template.png)

The template description reads:
> *Monitors MCP tool and method usage patterns, response sizes, and latency.*

Click **Use template** and save the dashboard.

### Explore the dashboard

The Agentic analytics dashboard opens with several panels:

![Agentic analytics dashboard showing MCP tool usage and latency]({{< baseurl >}}/images/211-agentic-dashboard-tool-usage.png)

| Panel | What it shows |
|-------|---------------|
| **Total MCP requests** | Total tool calls routed through the gateway |
| **Total MCP errors** | Failed calls — including the 401s from unauthenticated attempts |
| **Top 10 MCP Servers** | Request count, average latency, and error rate per upstream service |
| **Avg MCP latency by tool** | Latency trend over time, broken down by tool name (`getPolicy`, etc.) |
| **MCP tool usage** | Which tools are called most frequently |
| **MCP tool calls by agent** | Call volume attributed to each consumer identity |

### What to look for

- **Top 10 MCP Servers** will show both the shared gateway services and your
  own student gateway services (e.g. `student-01-policy-api-service`). You
  can see the error rate spike when you tested without the Bearer token.
- **Avg MCP latency by tool** shows a timeline for `getPolicy` — each spike
  corresponds to an agent run.
- **MCP tool calls by agent** will be populated once consumer mapping is
  configured. For now it reflects the requests made during the OAuth2 tests.

This is the same observability story from the LLM layer in Lab 1, now
applied to the MCP tool layer. Every tool call — approved, rejected, or
blocked — is visible in one place, attributed and timestamped.

---

→ Continue to **Summary**
