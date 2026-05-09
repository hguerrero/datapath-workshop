---
title: Listener
---

## Step 3 — Configure a Listener

A **listener** is the network endpoint that Kafka clients connect to. The data
plane binds to the port you specify and handles the Kafka protocol handshake.
A **port-mapping policy** on the listener routes incoming connections to the
correct virtual cluster.

### Create the listener

In your Event Gateway control plane, click
**Listeners → + New listener**.

| Field | Value |
|-------|-------|
| **Name** | `student-01-listener` _(replace with your student ID)_ |
| **Type** | Kafka |
| **Port** | `9092` + your student number _(e.g., student-01 → 9093, student-02 → 9094)_ |

> **Port assignment:** The instructor has allocated a unique port to each
> student. Check `$EVENT_GW_PORT` in your terminal: `echo $EVENT_GW_PORT`.

Click **Save**.

![Listener created showing port and type]({{< baseurl >}}/images/404-listener.png)

### Add a port-mapping policy

The listener is now bound to a port but doesn't know where to route traffic.
A **port-mapping policy** connects the listener port to your virtual cluster.

On the listener detail page, click **Policies → + Add policy**.

| Field | Value |
|-------|-------|
| **Type** | Port mapping |
| **Port** | Same port as above |
| **Virtual cluster** | `student-01-cluster` |

Click **Save**.

![Listener port-mapping policy linking to the virtual cluster]({{< baseurl >}}/images/405-listener-policy.png)

Now the data plane knows: connections arriving on your assigned port should be
authenticated and served by your virtual cluster.

### The connection chain so far

```
Client connects to $EVENT_GW_HOST:$EVENT_GW_PORT
    │
    ▼ Listener  (port mapping policy)
    │
    ▼ Virtual Cluster  student-01-cluster
        SASL/PLAIN auth  →  validate principal student-01
        Namespace         →  prepend student-01_ to all topics
        ACL mode          →  enforce_on_gateway  (all denied until next step)
    │
    ▼ Backend Cluster  student-01-kafka
    │
    ▼ Kafka broker  $KAFKA_BOOTSTRAP
```

At this point a client connecting would authenticate successfully but be
denied access to every topic because ACL mode is `enforce_on_gateway` with no
allow rules yet. You'll add those in the next step.

---

→ Continue to **Topic ACLs**
