---
title: Your First Decisions
---

## Step 4 — Try All Three Outcomes

Switch to the **Expense Agent** dashboard tab. The policy you read earlier
defines three decision paths. Use the example chips below the input field
to try each one — or type your own description.

### Approve — within policy

Click the **🍱 Team lunch · $150** chip and press **▶ Run Agent**.

Alice's spending limit is $200. The auto-approve limit is $200. Category
`meals` is not restricted. Expected outcome: **APPROVED**.

### Reject — prohibited category

Type this in the expense input and run the agent:

```
Bob (emp-002) is submitting $80 for alcohol at a client dinner.
```

The policy spec example marks `alcohol` as a prohibited category regardless
of amount. Expected outcome: **REJECTED**.

### Escalate — high value

Click the **✈️ Conference trip · $2,500** chip and run the agent.

The amount ($2,500) exceeds the escalation threshold ($1,000). Expected
outcome: **ESCALATED**.

### Escalate — restricted category

Type this and run:

```
Alice (emp-001) is expensing $400 for new headphones (equipment).
```

`equipment` is in the always-escalate category list even though the amount
is within Alice's spending limit. Expected outcome: **ESCALATED**.

---

### Observation

The agent reached different decisions based purely on context it gathered
via MCP tool calls. No decision logic lives in the agent code — it all
comes from the policy service and the LLM's interpretation of what it found.

**This is the key insight for governance:** if you want to change how
decisions are made, you change the policy service or the LLM behaviour —
both of which you control through Kong.

---

→ Continue to **Trace the Data Path**
