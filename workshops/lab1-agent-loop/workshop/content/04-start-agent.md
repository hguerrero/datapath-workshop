---
title: Start the Agent
---

## Step 3 — Start the Volcano Agent

Open `agent/src/agent.ts` and read through it. Notice three things:

1. **`tools` array** — three `mcp()` entries, each pointing at a `$PROXY/mcp/*`
   URL. The agent has no knowledge of the upstream REST APIs or how the Mocking
   plugin works; it only sees MCP tools discovered at those URLs.

2. **`llm.baseURL`** — reads `LLM_PROXY` from your `.env`. In Labs 1–2 this
   goes directly to OpenAI. In Lab 3 you change this one variable to route all
   LLM traffic through the Kong AI Gateway.

3. **`instructions`** — the system prompt tells the agent its four-step
   reasoning process: retrieve policy → look up employee → evaluate → act.
   The agent calls MCP tools to gather context before making a decision.

### Set up your environment

Copy the example env file and fill in your values:

```terminal:execute
command: cp agent/.env.example agent/.env
```

Open `agent/.env` and set at minimum:

```
PROXY=<your Kong gateway URL>       # provided by your instructor
OPENAI_API_KEY=<your key>
LLM_PROXY=https://api.openai.com    # direct to OpenAI in Lab 1
```

### Install dependencies

```terminal:execute
command: cd agent && npm install
```

### Run the agent with the default expense

```terminal:execute
command: cd agent && npm run dev
```

You should see the agent print its reasoning steps and a final decision.
The full trace will look something like:

```
────────────────────────────────────────────────────────────
Expense input:
Alice (emp-001) is submitting an expense of $150 for "Team lunch".
────────────────────────────────────────────────────────────

[tool call] policy → getPolicy
[tool call] hr     → getEmployee(emp-001)
[tool call] policy → evaluateExpense(amount=150, employeeId=emp-001, category=meals)
[tool call] expense → approveExpense(amount=150, description="Team lunch", employeeId="emp-001")

Agent decision:
The expense of $150 for "Team lunch" is approved. Alice's spending limit is $200
and the policy auto-approve limit is $200. Reference: EXP-A3F7C1B2.
```

> **What you're seeing:** Every `[tool call]` line is a real HTTP request
> from the agent through Kong to the mock route. Kong's AI MCP Proxy plugin
> converts it to an HTTP call, and the Mocking plugin returns the spec example.
> No external service is involved — the entire loop runs inside Kong.

### Try a different expense

Pass an expense directly on the command line:

```terminal:execute
command: cd agent && npm run dev -- "Bob (emp-002) is submitting \$2500 for cloud conference sponsorship."
```

Because the amount exceeds the escalation threshold (1000) in the policy spec
example, the agent should call `escalateExpense` instead of `approveExpense`.

---

→ Continue to **Your First Decision**
