---
title: Summary
---

## Lab 2 Complete

You started with an agent that approved everything based on general
reasoning. You ended with an agent that enforces your company's specific
expense policy — and can only do so using OAuth2-authenticated,
Kong-governed tool calls.

### What you built

```
Expense Agent  (Bearer token)
  │
  ├── /mcp/policy  ──▶ Kong (AI MCP OAuth2) ──▶ Policy MCP Server
  │                    token validated via Kong Identity
  │                    getPolicy → company rules
  │
  └── /llm          ──▶ Kong (AI Proxy) ──▶ OpenAI
                         gpt-4o-mini → decision
```

### What you did

1. Observed an agent approving a $250 expense with no policy context
2. Discovered the Policy MCP server via MCP Inspector and explored the
   `getPolicy` tool — with no credentials required
3. Connected the agent by setting the Proxy URL, enabling MCP tool calls
   through Kong
4. Ran the same $250 request — now rejected with a specific policy reason
5. Added the **AI MCP OAuth2** plugin to the `/mcp/policy` route, backed
   by a pre-provisioned Kong Identity authorization server
6. Retrieved an access token via client credentials grant and configured
   both MCP Inspector and the agent to present it as a Bearer token
7. Verified that unauthenticated access returns `401 Unauthorized`

### The pattern

| Layer | What it controls |
|-------|-----------------|
| MCP tool availability | Which tools the agent can discover and call |
| AI MCP OAuth2 plugin | Token validation — only authorized clients can reach the tool server |
| Kong Identity | Issues and introspects tokens; manages application credentials |
| Policy MCP content | What policy rules the agent reasons with |

Rotating credentials? Issue a new client secret in Kong Identity — no
gateway config changes needed. Revoking an agent's access? Disable its
application or revoke its token. Neither requires touching the agent code.

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
