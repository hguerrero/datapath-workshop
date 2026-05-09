---
title: Test & Verify
---

## Step 5 — Test and Verify

With the full chain configured you can now connect a Kafka client through the
Event Gateway using the same OAuth credentials from Lab 2, and verify that the
namespace prefix and ACLs work as expected.

### Confirm your environment variables

```bash
echo "Gateway host  : $EVENT_GW_HOST"
echo "Gateway port  : $EVENT_GW_PORT"
echo "Token endpoint: $TOKEN_ENDPOINT"
echo "Client ID     : $CLIENT_ID"
echo "Client secret : $CLIENT_SECRET"
```

All five should be set. If any are empty, ask the instructor.

### How OAUTHBEARER works with kcat

`kcat` uses **librdkafka** under the hood, which supports the OIDC client
credentials flow natively. Set `sasl.oauthbearer.method=oidc` and librdkafka
will fetch a token from the token endpoint automatically before connecting —
no manual `curl` required.

The gateway receives the token, validates it against Kong Identity's JWKS
endpoint, extracts the `sub` claim (your `$CLIENT_ID`), and evaluates your
ACL policies.

### List topics through the gateway

```bash
kcat -b $EVENT_GW_HOST:$EVENT_GW_PORT \
  -X security.protocol=SASL_SSL \
  -X sasl.mechanisms=OAUTHBEARER \
  -X sasl.oauthbearer.method=oidc \
  -X sasl.oauthbearer.client.id=$CLIENT_ID \
  -X sasl.oauthbearer.client.secret=$CLIENT_SECRET \
  -X sasl.oauthbearer.token.endpoint.url=$TOKEN_ENDPOINT \
  -L
```

You should see your pre-created topics **without** the student prefix:

```
Metadata for all topics (from broker -1: ...):
 3 topics:
  "expense-decisions" with 1 partitions:
  "audit-log" with 1 partitions:
  "agent-traces" with 1 partitions:
```

> The real topic names on the broker are `student-01_expense-decisions` etc.
> The namespace prefix is hidden — only the gateway knows about it.

### Produce a test message

```bash
echo '{"decision":"approved","amount":150,"submitter":"alice"}' | \
kcat -b $EVENT_GW_HOST:$EVENT_GW_PORT \
  -X security.protocol=SASL_SSL \
  -X sasl.mechanisms=OAUTHBEARER \
  -X sasl.oauthbearer.method=oidc \
  -X sasl.oauthbearer.client.id=$CLIENT_ID \
  -X sasl.oauthbearer.client.secret=$CLIENT_SECRET \
  -X sasl.oauthbearer.token.endpoint.url=$TOKEN_ENDPOINT \
  -t expense-decisions \
  -P
```

### Consume from the topic

```bash
kcat -b $EVENT_GW_HOST:$EVENT_GW_PORT \
  -X security.protocol=SASL_SSL \
  -X sasl.mechanisms=OAUTHBEARER \
  -X sasl.oauthbearer.method=oidc \
  -X sasl.oauthbearer.client.id=$CLIENT_ID \
  -X sasl.oauthbearer.client.secret=$CLIENT_SECRET \
  -X sasl.oauthbearer.token.endpoint.url=$TOKEN_ENDPOINT \
  -t expense-decisions \
  -C -o beginning -e
```

You should see the message you just produced:

![kcat consuming from expense-decisions topic via Event Gateway with OAUTHBEARER]({{< baseurl >}}/images/407-test-consume.png)

### Verify that an expired or missing token is rejected

Try connecting without any credentials to confirm the gateway enforces auth:

```bash
kcat -b $EVENT_GW_HOST:$EVENT_GW_PORT \
  -X security.protocol=SSL \
  -L
```

Expected result: the connection is refused or returns an authentication error.
Unlike in Lab 2, there is no fallback — every Kafka protocol connection must
present a valid OAUTHBEARER token.

### Verify namespace isolation

Try to read a topic outside your namespace using its full broker name:

```bash
kcat -b $EVENT_GW_HOST:$EVENT_GW_PORT \
  -X security.protocol=SASL_SSL \
  -X sasl.mechanisms=OAUTHBEARER \
  -X sasl.oauthbearer.method=oidc \
  -X sasl.oauthbearer.client.id=$CLIENT_ID \
  -X sasl.oauthbearer.client.secret=$CLIENT_SECRET \
  -X sasl.oauthbearer.token.endpoint.url=$TOKEN_ENDPOINT \
  -t student-02_expense-decisions \
  -C -o beginning -e
```

Expected result: `%3|...: UNKNOWN_TOPIC_OR_PART` — the topic doesn't exist
from the virtual cluster's perspective because the namespace boundary blocks
access to any topic not starting with your prefix.

### What you've verified

| Test | Result |
|------|--------|
| List topics | Only your prefixed topics visible (without prefix) |
| Produce to your topic | Success — token validated, ACL passed |
| Consume from your topic | Success — message appears |
| Connect without a token | Rejected — auth enforced at gateway |
| Access another student's topic | Denied — namespace isolation enforced |

---

→ Continue to **Summary**
