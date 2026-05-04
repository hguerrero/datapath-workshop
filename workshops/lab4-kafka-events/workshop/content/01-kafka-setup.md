---
title: Kafka Setup
---

## Step 1 — Start the Kafka Broker

Start the local Kafka broker (KRaft mode — no ZooKeeper needed):

```bash
docker compose --profile kafka up -d kafka
```

Wait for the broker to be ready:

```bash
docker compose logs kafka | grep "started"
```

You should see: `KafkaServer ... started`

### Verify the broker is reachable

```bash
docker compose exec kafka \
  kafka-broker-api-versions --bootstrap-server localhost:9092
```

### Open the Kafka UI (optional)

```bash
docker compose --profile kafka up -d kafka-ui
```

Navigate to `http://localhost:8080` — you will see the Confluent Kafka UI
where you can browse topics and messages as events arrive.

### Create the topic

```bash
docker compose exec kafka \
  kafka-topics --create \
    --bootstrap-server localhost:9092 \
    --topic expense-decisions \
    --partitions 3 \
    --replication-factor 1
```

Confirm it was created:

```bash
docker compose exec kafka \
  kafka-topics --list --bootstrap-server localhost:9092
```

---

→ Continue to **Decision Events**
