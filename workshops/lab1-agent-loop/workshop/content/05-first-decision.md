---
title: Your First Decision
---

## Step 4 — Try All Three Outcomes

The policy service defines three decision paths. Try each one.

### Approve

Within Alice's spending limit, compliant category:

```bash
npm run dev -- "Alice (emp-001) wants to expense \$150 for a team lunch"
```

Expected outcome: **approved**

### Reject

Prohibited category:

```bash
npm run dev -- "Bob (emp-002) is submitting \$80 for alcohol at a client dinner"
```

Expected outcome: **rejected** — the policy service flags `alcohol` as a
prohibited category regardless of amount.

### Escalate — high value

Above the escalation threshold ($1000):

```bash
npm run dev -- "Bob (emp-002) is submitting \$2500 for a conference in Austin"
```

Expected outcome: **escalated** — two rules fire: the amount exceeds
$1000 and `conference` is an always-escalate category.

### Escalate — restricted category

```bash
npm run dev -- "Alice (emp-001) is expensing \$400 for new headphones (equipment)"
```

Expected outcome: **escalated** — `equipment` is in the always-escalate
category list even though Alice's spending limit is $200.

---

### Observation

The agent reached four different decisions based purely on context it gathered
via MCP tool calls. No decision logic lives in the agent code — it all comes
from the policy service and the LLM's interpretation of what it found.

**This is the key insight for governance:** if you want to change how
decisions are made, you change the policy service or the LLM behaviour —
both of which you control through Kong.

---

→ Continue to **Trace the Data Path**
