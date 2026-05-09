---
title: Policy in Action
---

## Step 4 — Watch Policy Reject the Same Expense

Now that the Proxy URL is configured, run the exact same request you ran in
Step 1.

### Submit Alice's expense again

In the **Expense request** field, use the same input:

> *Alice (emp-001) is submitting $250 for a team lunch.*

Click **Run Agent**.

![Same request — now REJECTED with a specific policy reason]({{< baseurl >}}/images/205-test-expense-with-policy-mcp.png)

This time the result is: **REJECTED**.

The agent response explains exactly why:

> *"REJECT: The expense is for $250, which exceeds the automatic approval
> limit of $200, and it is not categorized as travel, conference, or
> equipment that would require escalation, but it also lacks a receipt as
> it crosses the $75 threshold."*

### What changed

Nothing changed in the agent code. The only difference is that the agent
now has a **Proxy URL**, which means it can discover and call MCP tools via
Kong. On this run it:

1. Called `getPolicy` on the Policy MCP server at `/mcp/policy`
2. Retrieved the company's expense rules ($200 auto-approval limit, receipt
   requirement above $75, category restrictions)
3. Applied those rules to Alice's request
4. Returned a rejection with the specific policy clause that was violated

The model didn't change. The prompt didn't change. The policy server added
context — and the decision changed completely.

### Try another example

Use the pre-loaded examples in the agent UI to explore more cases:

| Request | Expected result |
|---------|----------------|
| Team lunch · $150 | Approved (under $200 limit) |
| Conference trip · $2,500 | Escalated (travel category, high value) |
| Office supplies · $89 | Approved (with receipt note) |
| Client dinner · $340 | Rejected (exceeds limit, not an approved category) |

---

→ Continue to **Secure the MCP Server**
