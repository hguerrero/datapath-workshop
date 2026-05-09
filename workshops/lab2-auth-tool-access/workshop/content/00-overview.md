---
title: Overview
---

## Lab 2 — MCP Tool Access & Policy

In Lab 1 you put the LLM call behind Kong. The agent went from talking
directly to OpenAI to routing every inference request through your gateway —
giving you visibility and control over the model layer.

But the agent is still making decisions in a vacuum. It knows nothing about
**your company's expense policies**. It reasons from general knowledge, and
general knowledge says a $250 team lunch sounds fine.

This lab adds the missing context — a **Policy MCP server** that the agent
can call to retrieve the actual corporate rules before it decides anything.

### What you will do

```
Lab 1 result:
  Agent ──▶ Kong /llm ──▶ OpenAI
  (no policy context — approves on general reasoning)

Lab 2 result:
  Agent ──▶ Kong /mcp/policy ──▶ Policy Server  ← new
        ──▶ Kong /llm         ──▶ OpenAI
  (fetches company rules first, then decides)
```

1. **See the gap** — run Alice's $250 expense and watch it get approved with no justification
2. **Discover the Policy MCP server** — explore it with MCP Inspector and find the `getPolicy` tool
3. **Connect the agent** — point the agent at Kong's proxy so it can reach the MCP server
4. **See policy kick in** — same request, now rejected with a specific policy reason
5. **Secure the MCP server** — it's currently open to anyone; add OAuth2 authentication using Kong Identity

### The governance insight

You will not change any business logic in the agent. The agent discovers
available tools at runtime via MCP. Add a new MCP server behind Kong and the
agent automatically gains access to it — or you can lock it down so only
authorised callers can connect.

---

→ Continue to **Approve Without Policy**
