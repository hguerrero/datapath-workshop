---
title: Summary
---

## Lab 2 Complete

You started with an agent that approved everything based on general
reasoning. You ended with an agent that enforces your company's specific
expense policy — and can only do so using authenticated, Kong-governed
tool calls.

### What you built

```
Expense Agent
  │
  ├── /mcp/policy  ──▶ Kong (Key Auth) ──▶ Policy MCP Server
  │                    getPolicy → company rules
  │
  └── /llm          ──▶ Kong (AI Proxy) ──▶ OpenAI
                         gpt-4o-mini → decision
```

### What you did

1. Observed an agent approving a $250 expense with no policy context
2. Discovered a Policy MCP server via MCP Inspector and explored the
   `getPolicy` tool
3. Copied the Kong Proxy URL from Konnect and configured the agent to
   route MCP calls through Kong
4. Ran the same $250 request — now rejected with a specific policy reason
5. Added Key Authentication to the `/mcp/policy` route, created an
   `expense-agent` consumer, and issued an API key
6. Verified that unauthenticated access to the policy server is blocked

### The pattern

| Layer | What it controls |
|-------|-----------------|
| MCP tool availability | Which tools the agent can discover and call |
| Kong Key Auth | Which callers are allowed to reach each tool server |
| Kong consumers | Named identity for each agent — auditable and rate-limitable |
| Policy MCP content | What policy rules the agent reasons with |

Changing the company expense policy? Update the Policy MCP server.
Revoking an agent's access? Delete or disable its consumer credential.
Neither requires touching the agent code.

### What's still open

The LLM call now goes through Kong's AI Gateway (from Lab 1), but there
are no guardrails on what the agent can ask the model. A malicious or
misconfigured request could still leak sensitive data or consume excessive
tokens.

Lab 3 adds prompt inspection and token rate limiting directly at the
gateway.

---

## Next: Lab 3 — LLM Governance

In Lab 3 you will apply AI-specific plugins to the `/llm` route: prompt
guardrails to block sensitive data, token rate limiting to control spend,
and semantic caching to reduce redundant LLM calls.
