---
title: Summary
---

## Lab 2 Complete

Your data path now has identity and access control at every tool hop:

```
Client
  │
  ▼
Kong  (Key Auth + ACL)
  ├── /mcp/expense  ── requires apikey ── requires group: escalation-approved
  ├── /mcp/hr       ── requires apikey
  └── /mcp/policy   ── requires apikey
  │
  ▼
Volcano Agent  (sends apikey header on all calls)  ──▶  LLM (direct)
```

### What you learned

- **Key auth** turns anonymous requests into identified requests — one plugin,
  zero code changes.
- **Consumers** give the agent a first-class identity that Kong can
  report on, rate limit, and ACL-scope independently.
- **ACL groups** let you define tool access roles externally. The agent never
  knows which tools it's allowed to call — it just tries, and Kong decides.
- **Audit logs** give you a full attribution trail of which agent made which
  tool call and when.

### What's still missing

The LLM call still bypasses Kong. That means:

- No rate limiting on LLM spend
- No failover if the LLM provider goes down
- No prompt guardrails
- No visibility into what the agent is sending to the LLM

Lab 3 fixes this.

---

## Next: Lab 3 — LLM Governance

In Lab 3 you will route all LLM traffic through Kong's AI Gateway and apply
rate limiting, multi-provider failover, and prompt guardrails — without
touching the agent code.

[→ Start Lab 3](../../lab3-llm-governance/)
