---
title: Topic ACLs
---

## Step 4 — Add Topic ACL Policies

With `acl_mode: enforce_on_gateway`, Event Gateway denies all topic operations
by default. You need explicit allow rules before any client can produce or
consume. ACL policies on the virtual cluster define exactly which topics a
principal can access and what they can do with them.

### Understanding the principal with OAuth

When a Kafka client authenticates using OAUTHBEARER, the gateway validates the
JWT against your Kong Identity issuer and extracts the **`sub` claim** as the
principal. For a client credentials grant, the `sub` is the **client ID** of
your OAuth application.

Confirm your client ID — this is what you'll use as the principal in every ACL
rule:

```bash
echo $CLIENT_ID
```

### Understanding the ACL model

Because the virtual cluster has a **namespace with hide_prefix**, clients refer
to topics *without* the prefix. ACL rules also use the unprefixed names — the
gateway resolves the full topic name internally.

```
Client requests topic:   expense-decisions
Namespace resolves to:   student-01_expense-decisions  (on the broker)
ACL checks against:      expense-decisions              (pre-prefix form)
OAuth sub claim:         <your CLIENT_ID>               (the principal)
```

### Add an allow-all rule for your topics

For this lab, you'll add a broad rule that allows your OAuth principal to
describe, read, and write any topic visible through the virtual cluster.
Because the namespace already constrains visibility to your `student-01_`
prefix, this is safe — "any topic" here means "any of *your* topics."

On your virtual cluster detail page, click **ACL Policies → + Add ACL policy**.

| Field | Value |
|-------|-------|
| **Principal** | _(paste the value of `$CLIENT_ID`)_ |
| **Resource type** | Topic |
| **Resource names** | `*` |
| **Match type** | Literal |
| **Operations** | `Describe`, `Read`, `Write` |
| **Effect** | Allow |

Click **Save**.

![ACL policy showing allow rule for OAuth client ID on all topics]({{< baseurl >}}/images/406-acl-policy.png)

### Add a consumer group rule

Kafka consumers use consumer groups to track offsets. Add a second rule for
the consumer group resource type:

| Field | Value |
|-------|-------|
| **Principal** | _(same `$CLIENT_ID` value)_ |
| **Resource type** | Consumer group |
| **Resource names** | `*` |
| **Match type** | Literal |
| **Operations** | `Describe`, `Read` |
| **Effect** | Allow |

Click **Save**.

### What deny-first enforcement means

With `enforce_on_gateway`, the gateway acts as the policy decision point — not
the Kafka broker. Even if the broker has no ACLs configured, clients can't
bypass your rules by connecting directly. The gateway is the only path in.

This is the same pattern you applied in Labs 2 and 3: default-deny, then
explicit allow for what's needed. Applied here at the Kafka protocol layer,
with identity coming from the same OAuth token as the rest of the data path.

---

→ Continue to **Test & Verify**
