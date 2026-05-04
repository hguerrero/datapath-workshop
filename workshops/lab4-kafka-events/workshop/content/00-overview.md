---
title: Overview
---

## Lab 4 — Kafka Event Trail (Optional)

This lab adds one more hop to the governed data path: every expense decision
the agent makes is also published as a Kafka event, giving you an immutable
audit trail and the foundation for event-driven downstream systems.

```
Before:
  Agent  ──▶  Kong  ──▶  expense-service  ──▶  (decision stored in memory)

After:
  Agent  ──▶  Kong  ──▶  expense-service  ──▶  decision stored in memory
                  │
                  └──▶  Kafka topic: expense-decisions  ──▶  consumers...
```

The key point: **Kong publishes the event**. The agent doesn't know about
Kafka. The expense-service doesn't know about Kafka. Kong intercepts the
request and fans it out — zero code changes on either side.

### What you'll do

1. Start a local Kafka broker
2. Add Kong's Kafka Upstream plugin to the decision route
3. Run the agent and watch decisions land in the Kafka topic
4. Consume events and explore downstream patterns

### Prerequisites

This lab can be run standalone or on top of Labs 1–3. If running standalone,
complete Lab 1 first to set up the mock APIs and agent. The Kafka plugin
does not depend on Labs 2 or 3.

---

→ Continue to **Kafka Setup**
