---
title: Overview
---

## Lab 3 — LLM Governance

After Labs 1 and 2, your data path looks like this:

```
Agent  ──▶  LLM (direct — no gateway)   ← gap
Agent  ──▶  Kong  ──▶  MCP tools        ← governed
```

The LLM call is the one hop you haven't controlled yet. In production, this
means unmetered spend, no fallback if the provider goes down, and no
visibility into what prompts the agent is sending.

In this lab you close that gap entirely — using only Kong config changes:

```
Agent  ──▶  Kong AI Gateway  ──▶  LLM   ← now governed
Agent  ──▶  Kong             ──▶  MCP tools
```

The agent code change is **one line** in `.env`:

```diff
-LLM_PROXY=https://api.openai.com
+LLM_PROXY=https://$PROXY/llm
```

Everything else — rate limiting, failover, guardrails, caching — is Kong
configuration.

### What you'll do

1. Create a Kong AI Gateway route for LLM calls
2. Add rate limiting to control LLM spend per consumer
3. Configure multi-provider failover (OpenAI → Anthropic)
4. Add the AI Prompt Guard plugin to block policy violations
5. Enable semantic caching to reduce redundant LLM calls
6. Observe the full data path — tool calls AND LLM calls — in one place

---

→ Continue to **AI Gateway Setup**
