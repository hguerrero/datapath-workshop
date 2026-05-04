---
title: Test Access Control End-to-End
---

## Step 5 — Full Agent Run with Auth

Run the agent through all four scenarios from Lab 1:

```bash
cd agent

# Approve
npm run dev -- "Alice (emp-001) wants to expense \$150 for a team lunch"

# Reject
npm run dev -- "Bob (emp-002) is submitting \$80 for alcohol at a client dinner"

# Escalate
npm run dev -- "Bob (emp-002) is submitting \$2500 for a conference in Austin"
```

All three should still work — the agent is authenticated and authorised.

### Test with a missing key

Temporarily remove the API key and confirm the agent is blocked:

```bash
AGENT_API_KEY="" npm run dev -- "Alice (emp-001) wants to expense \$50 for coffee"
```

Expected: the agent's first tool call fails with `401 Unauthorized` and the
run aborts.

### Test with a key from an unknown consumer

```bash
AGENT_API_KEY="invalid-key-xyz" npm run dev -- "test"
```

Expected: `401 Unauthorized`

### What Kong now enforces for every single agent run

| Check | Enforced by |
|-------|-------------|
| Request has a valid API key | Key Auth plugin |
| Key belongs to a known consumer | Kong consumer database |
| Consumer is in the required ACL group | ACL plugin |
| All of the above logged with consumer identity | Konnect Analytics |

---

→ Continue to **Audit Logs**
