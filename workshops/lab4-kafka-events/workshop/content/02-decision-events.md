---
title: Decision Events
---

## Step 2 — Publish Decisions as Kafka Events

Add Kong's **Kafka Upstream** plugin to the expense MCP route. When the
plugin is set to `request-response` mode, Kong forwards the request to both
the upstream service (expense-service) AND publishes the request body as a
Kafka message. The agent receives the upstream response as normal.

### Add the Kafka Upstream plugin

In the Konnect UI, navigate to the `expense-mcp` route and add
**Kafka Upstream**:

| Field | Value |
|-------|-------|
| Bootstrap servers | `localhost:9092` (or `$KAFKA_BOOTSTRAP`) |
| Topic | `expense-decisions` |
| Timeout | `10000` |
| Keepalive | `60000` |
| Forward method | `true` |
| Forward URI | `true` |
| Forward headers | `true` |
| Forward body | `true` |

> **Mode:** By default the Kafka Upstream plugin replaces the upstream call
> with a Kafka publish (the response is `200 {"message":"message sent"}`).
> For this lab we want to keep the expense-service response and also publish
> to Kafka. Use the **Kafka Log** plugin instead if you want both:

**Alternative — Kafka Log plugin** (recommended for this lab):

This plugin publishes request/response data as a log entry to Kafka without
affecting the upstream call:

| Field | Value |
|-------|-------|
| Bootstrap servers | `localhost:9092` |
| Topic | `expense-decisions` |

The Kafka Log plugin runs after the upstream response — so every decision
that the expense-service records also gets published to Kafka, with both the
request (what the agent decided) and the response (the record ID).

### Sync via decK

```bash
deck gateway sync decK/lab4-kafka-events/kong.yaml \
  --konnect-token $KONNECT_TOKEN \
  --konnect-control-plane-name $CP_NAME
```

---

→ Continue to **Consume Events**
