---
title: Virtual Cluster
---

## Step 2 — Create a Virtual Cluster

A **virtual cluster** is the tenant-facing abstraction: it defines what a
specific client sees and is allowed to do. Each student in this workshop gets
their own virtual cluster so you can't accidentally read or write another
student's topics, even though everyone shares the same Kafka broker.

Two settings make this work:

- **Namespace** — a prefix that Event Gateway prepends to every topic name
  before forwarding to the backend cluster. With `hide_prefix` mode enabled,
  clients see topic names *without* the prefix — the gateway adds and strips it
  transparently.
- **ACL mode** — set to `enforce_on_gateway` so all topic access is denied by
  default. You'll add explicit allow rules in Step 4.

### Create the virtual cluster

In your Event Gateway control plane, click
**Virtual Clusters → + New virtual cluster**.

#### Basic settings

| Field | Value |
|-------|-------|
| **Name** | `student-01-cluster` _(replace with your student ID)_ |
| **Backend cluster** | Select `student-01-kafka` (created in Step 1) |
| **ACL mode** | `enforce_on_gateway` |

#### Authentication

Under **Authentication**, choose **OAuth 2.0 / OIDC**.

Set the **Issuer URL** to your Kong Identity authorization server — this is the
same issuer you used in Lab 2:

```bash
echo $ISSUER_URL
```

| Field | Value |
|-------|-------|
| **Issuer URL** | `$ISSUER_URL` _(copy from terminal output above)_ |

Event Gateway will use the issuer's OpenID Connect discovery document
(`/.well-known/openid-configuration`) to find the JWKS endpoint and validate
incoming tokens automatically. There are no principals to configure manually —
identity comes from the OAuth token your Kafka client presents.

> **Reusing Lab 2's auth server:**
> Your Kong Identity authorization server from Lab 2 serves double duty here.
> The same client credentials you used to retrieve a Bearer token for the MCP
> server are what your Kafka client will use to authenticate to the Event
> Gateway. One identity provider, two governed protocols.

#### Namespace

Toggle **Namespace** on and set:

| Field | Value |
|-------|-------|
| **Prefix** | `student-01_` _(your student ID followed by underscore)_ |
| **Mode** | `hide_prefix` |

With `hide_prefix`, a client producing to topic `expense-decisions` will
actually write to `student-01_expense-decisions` on the broker — and reading
`expense-decisions` reads from `student-01_expense-decisions`. The prefix is
invisible to the client.

Click **Save**.

![Virtual cluster created with OAuth OIDC auth and namespace prefix]({{< baseurl >}}/images/403-virtual-cluster.png)

### Find your OAuth principal name

When a Kafka client authenticates with OAUTHBEARER, the gateway extracts the
`sub` claim from the JWT and uses it as the principal for ACL evaluation. For
Kong Identity with a client credentials grant, the `sub` claim is the
**client ID** of your OAuth application.

Retrieve your client ID and confirm it:

```bash
echo $CLIENT_ID
```

You'll use this value as the principal when creating ACL policies in Step 4.

> **Multi-tenancy on a shared cluster:**
> Every student uses the same Kafka broker. The namespace prefix creates hard
> topic-level isolation, and each student's OAuth token maps to a distinct
> client ID — so ACL rules apply per-tenant without any broker-side
> configuration.

---

→ Continue to **Listener**
