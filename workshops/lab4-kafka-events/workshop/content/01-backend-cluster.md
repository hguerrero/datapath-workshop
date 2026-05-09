---
title: Backend Cluster
---

## Step 1 — Create a Backend Cluster

A **backend cluster** is Event Gateway's abstraction of the real Kafka cluster.
It stores the bootstrap servers and credentials needed to reach the broker.
All virtual clusters you create later will reference this backend cluster as
their upstream destination.

### Navigate to your Event Gateway control plane

In Konnect, open **Gateway Manager** and select your **Event Gateway control
plane** — it will be named something like `student-01-event-gw`.

![Event Gateway control plane in Konnect Gateway Manager]({{< baseurl >}}/images/401-event-gateway-cp.png)

The left-hand navigation shows the Event Gateway entity tree:
**Backend Clusters**, **Virtual Clusters**, and **Listeners**.

### Create the backend cluster

Click **Backend Clusters → + New backend cluster**.

Fill in the form:

| Field | Value |
|-------|-------|
| **Name** | `student-01-kafka` (replace with your student ID) |
| **Bootstrap servers** | `$KAFKA_BOOTSTRAP` |
| **Authentication type** | Plain |
| **Username** | `kafka` |
| **Password** | _(provided by instructor)_ |
| **TLS** | Enabled |

> **Note:** The `$KAFKA_BOOTSTRAP` value is available as an environment variable
> in your terminal. Run `echo $KAFKA_BOOTSTRAP` to confirm the broker address
> before typing it into the form.

Click **Save**.

![Backend cluster created showing bootstrap server and TLS status]({{< baseurl >}}/images/402-backend-cluster.png)

Konnect will show the backend cluster in **Connected** status once the data
plane verifies the connection to the broker.

> **Why a backend cluster abstraction?**
> Multiple virtual clusters can point to the same backend cluster. You change
> the broker address once — all virtual clusters pick it up. This also means
> your clients never have the real broker address: they connect to the listener
> and Event Gateway proxies the Kafka protocol transparently.

---

→ Continue to **Virtual Cluster**
