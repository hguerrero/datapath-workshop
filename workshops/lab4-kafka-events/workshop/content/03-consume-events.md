---
title: Consume Events
---

## Step 3 — Watch Decisions Arrive in Kafka

### Open a consumer in one terminal

```bash
docker compose exec kafka \
  kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic expense-decisions \
    --from-beginning \
    --formatter kafka.tools.DefaultMessageFormatter \
    --property print.key=true \
    --property print.value=true
```

Leave this running.

### Run the agent in a second terminal

```bash
cd agent

npm run dev -- "Alice (emp-001) wants to expense \$150 for a team lunch"
```

In the first terminal you should immediately see a JSON message arrive:

```json
{
  "request": {
    "method": "POST",
    "uri": "/mcp/expense",
    "body": "...",
    "headers": {
      "apikey": "expense-agent",
      "content-type": "application/json"
    }
  },
  "response": {
    "status": 200,
    "body": {
      "id": "EXP-A3F7C1B2",
      "status": "approved",
      "amount": 150,
      ...
    }
  },
  "consumer": {"username": "expense-agent"},
  "latencies": {"request": 12, "kong": 2, "proxy": 10},
  "started_at": 1748563200000
}
```

### Run all three decision types

```bash
npm run dev -- "Bob (emp-002) is submitting \$80 for alcohol at a client dinner"
npm run dev -- "Bob (emp-002) is submitting \$2500 for a conference in Austin"
```

Watch all three events land in the topic. Each event contains the full
request context (who called, what tool, what arguments) and the full
upstream response (record ID, status, timestamp).

### Browse in the Kafka UI

Open `http://localhost:8080` → Topics → `expense-decisions` → Messages.

You can filter by key, browse by offset, and inspect individual message
payloads — useful for debugging agent reasoning in production.

---

→ Continue to **Governance Patterns**
