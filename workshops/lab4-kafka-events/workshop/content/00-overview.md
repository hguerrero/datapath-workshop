---
title: Overview
---

## Lab 4 — Governing the Way Out

Every lab so far has governed the **way in**: what context the agent is
allowed to retrieve, from which sources, under which identity.

- **Lab 1** established the LLM proxy — every inference call is routed,
  observable, and rate-limited before it reaches a model.
- **Lab 2** introduced MCP tool access — the agent can only call policy tools
  through an authenticated, governed route.
- **Lab 3** added LLM governance plugins — token budgets, failover, prompt
  guards, and semantic caching on the retrieval path.

But governance of an AI data path isn't only about retrieval. Every decision
the agent makes is also a **write** — a mutation that flows back out into your
systems. If that outbound channel is uncontrolled, you have half a governance
story.

```
Way in  (retrieval)                     Way out  (mutation)
─────────────────────────────────────── ──────────────────────────────────────
Agent → Kong → /llm → OpenAI            Agent decision → ??? → downstream
Agent → Kong → /mcp/policy → MCP server
```

Lab 4 closes that gap. Kong Event Gateway sits on the outbound channel and
brings the same principles — identity, isolation, default-deny — to the Kafka
event stream that carries every agent decision.

```
Way in  (retrieval)                     Way out  (mutation)
─────────────────────────────────────── ──────────────────────────────────────
Agent → Kong → /llm → OpenAI            Kafka client
Agent → Kong → /mcp/policy → MCP server     │  OAUTHBEARER (Kong Identity)
                                            ▼
                                        Kong Event Gateway
                                            │  namespace · ACLs · TLS
                                            ▼
                                        Shared Kafka Broker
                                            expense-decisions
                                            audit-log
                                            agent-traces
```

The same Kong Identity authorization server from Lab 2 is the identity
provider here. The same default-deny ACL philosophy from Labs 2 and 3 is
applied at the Kafka protocol layer. One control plane, both directions.

### What's already provisioned

The instructor has set up everything you need to get started:

| Component | Status | Details |
|-----------|--------|---------|
| Kafka cluster | ✅ Running | Topics pre-created with your `$STUDENT_ID_` prefix |
| Event Gateway control plane | ✅ Running | Visible in your Konnect organisation |
| Event Gateway data plane | ✅ Running | Accepting Kafka client connections |

Your job is to wire up the configuration on the control plane: a **backend
cluster** (points to the real Kafka broker), a **virtual cluster** (your
tenant-isolated view with OAuth and a namespace), a **listener** (the port
clients connect to), and **ACL policies** (which topics your identity can use).

### What you'll build

```
Listener  :$EVENT_GW_PORT
    │  port-mapping policy
    ▼
Virtual Cluster  student-01-cluster
    │  Auth:      OAuth 2.0 / OIDC  →  Kong Identity  (same IdP as Lab 2)
    │  Namespace: prefix = student-01_  ·  mode = hide_prefix
    │  ACL mode:  enforce_on_gateway
    ▼
Backend Cluster  student-01-kafka
    ▼
Shared Kafka Broker  $KAFKA_BOOTSTRAP
```

### Steps

1. Create a **backend cluster** pointing at the shared Kafka broker
2. Create a **virtual cluster** — OAuth auth via Kong Identity, namespace prefix for isolation
3. Configure a **listener** with a port-mapping policy
4. Add **ACL policies** using your OAuth client ID as the principal
5. Test with `kcat` — token fetched automatically via OAUTHBEARER/OIDC

---

→ Continue to **Backend Cluster**
