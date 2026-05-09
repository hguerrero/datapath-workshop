---
title: Summary
---

## Lab 4 — Summary

You've closed the governance loop. The data path is now governed in both
directions: the way in and the way out.

### What you built

```
Kafka Client (kcat)
    │  Kafka protocol · OAUTHBEARER · TLS
    │  sasl.oauthbearer.method=oidc → fetches token from Kong Identity
    ▼
Listener  student-01-listener  :$EVENT_GW_PORT
    │  port-mapping policy
    ▼
Virtual Cluster  student-01-cluster
    │  Auth:      OAuth 2.0 / OIDC  ·  issuer = $ISSUER_URL
    │  Principal: sub claim from JWT  =  $CLIENT_ID
    │  Namespace: prefix = student-01_  ·  mode = hide_prefix
    │  ACL mode:  enforce_on_gateway
    │  ACLs:      $CLIENT_ID → allow describe/read/write on topics/*
    ▼
Backend Cluster  student-01-kafka
    │  TLS · SASL/PLAIN  (gateway → broker)
    ▼
Shared Kafka Broker  $KAFKA_BOOTSTRAP
    Topics: student-01_expense-decisions
            student-01_audit-log
            student-01_agent-traces
```

### Patterns you applied

| Pattern | What it does |
|---------|--------------|
| **Backend cluster** | Abstracts the real broker — clients never see the bootstrap address |
| **Virtual cluster + namespace** | Creates a scoped, prefixed view of the topic space per tenant |
| **hide_prefix mode** | Strips the namespace prefix from the client view — transparent multi-tenancy |
| **OAuth 2.0 / OIDC auth** | Token validated against Kong Identity; `sub` claim becomes the Kafka principal |
| **enforce_on_gateway ACL mode** | Default-deny at the gateway; topics require explicit allow rules |
| **Port-mapping policy** | Routes a listener port to a specific virtual cluster |

### The complete governed data path

Across all four labs you've built a full governance layer over an AI agent —
controlling both what it retrieves and what it emits.

```
                    ┌─────────────────────────────────────────┐
                    │           Kong Control Plane             │
                    │  (one place to see and control it all)  │
                    └─────────────────────────────────────────┘

WAY IN  (retrieval)                     WAY OUT  (mutation)
─────────────────────────────────────── ──────────────────────────────────────
Lab 1 · Lab 3                           Lab 4
/llm → AI Proxy → OpenAI                Kafka client
  AI Rate Limiting (token budget)           │  OAUTHBEARER
  Multi-provider failover                   ▼
  AI Prompt Guard                       Event Gateway
  Semantic Cache                            │  namespace · ACLs
                                            ▼
Lab 2                                   Shared Kafka Broker
/mcp/policy → Policy MCP Server             expense-decisions
  AI MCP OAuth2                             audit-log
  Kong Identity                             agent-traces

          ↑                                      ↑
    govern what the agent                 govern what the agent
    is allowed to know                    is allowed to write
```

Every component — the LLM proxy, the MCP route, the event stream — is
authenticated through the same **Kong Identity** authorization server. Your
OAuth client credentials from Lab 2 work at both the HTTP layer (MCP tool
calls) and the Kafka protocol layer (event writes). One identity, one control
plane, full coverage.

### What Kong Event Gateway adds beyond a Kafka plugin

| Kafka plugin approach | Kong Event Gateway |
|-----------------------|--------------------|
| HTTP request → Kafka topic | Native Kafka protocol (port 9092/9093) |
| Plugin config per route | Dedicated entity model (cluster → virtual cluster → listener) |
| No client auth | OAUTHBEARER via Kong Identity — same IdP as MCP and LLM layers |
| No topic isolation | Namespace + hide_prefix per tenant |
| Kafka ACLs on broker | ACLs enforced at gateway, broker untouched |

### Optional challenges

- Add a **deny rule** for a specific topic and verify your client is blocked
- Create a **second virtual cluster** with a different prefix and compare what
  each one sees when listing topics
- Connect a downstream consumer using its own OAuth credentials and separate
  ACL rules — observer identity distinct from writer identity

---

You've now governed the full AI data path: what flows into context, how models
are called, which tools an agent can use, and where its decisions land — all
from a single control plane, with no changes to agent or application code.
