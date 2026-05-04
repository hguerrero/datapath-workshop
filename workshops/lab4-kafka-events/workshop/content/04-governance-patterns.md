---
title: Governance Patterns
---

## Step 4 — What You Can Build Downstream

The Kafka topic is the foundation for several governance patterns that are
impossible (or very costly) to implement inside the agent itself.

### Pattern 1 — Anomaly detection

A consumer monitors the topic and fires an alert if:
- More than 5 escalations arrive from the same `employeeId` in one hour
- An `approveExpense` call is made for an amount above the auto-approve limit
  (which would indicate the agent overrode policy)
- Two decisions arrive for the same `description` within 60 seconds
  (possible duplicate submission)

None of this logic lives in the agent or the expense-service. It's a
stateless consumer reading from an immutable log.

### Pattern 2 — Compliance replay

Because Kafka retains messages, you can replay the full history of agent
decisions for a compliance audit. Query by `consumer.username`, time range,
or decision status — even after the in-memory expense-service has been
restarted and its records cleared.

```bash
docker compose exec kafka \
  kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic expense-decisions \
    --from-beginning | \
  jq 'select(.response.body.status == "escalated")'
```

### Pattern 3 — Human-in-the-loop trigger

An escalation event in Kafka can trigger a workflow (Slack notification,
Jira ticket, email to the manager). The expense-service doesn't need to
know about any of these systems — it records the decision; Kafka distributes
it; consumers act on it.

### Pattern 4 — Policy hot-reload

A policy administrator publishes a message to a `policy-updates` topic.
A consumer reads it and calls the policy-service's admin endpoint to update
the rules. The next agent run picks up the new policy with no restarts.

### The governing insight

Kafka turns individual agent decisions into a **shared, ordered, replayable
event stream**. Kong is the producer — it publishes events automatically on
every tool call. The agent and all downstream systems are decoupled.

---

→ Continue to **Summary**
