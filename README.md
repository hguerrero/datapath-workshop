# Kong Data Path Workshop

Hands-on Educates workshop series covering how Kong Gateway governs **every hop of an AI agent's data path** — from the initial client request, through the agent's reasoning loop, across MCP tool calls, LLM inference, and (optionally) event streaming via Kafka.

The series is built around a realistic expense-approval agent written with the [Volcano Agent SDK](https://volcano.dev). Mock back-end APIs are exposed as MCP tools through Kong's AI MCP Proxy Plugin (the same technique as [Kong MCP Workshop — Lab 1](https://github.com/Kong/kong-mcp-workshop)), so students who have completed that series will recognize the pattern immediately.

Labs 1–3 are the core series. Lab 4 (Kafka) is optional and can be run independently.

---

## Workshop Series

| Lab | Title | Focus | Steps |
|-----|-------|-------|-------|
| [Lab 1](workshops/lab1-agent-loop/) | **The Agent Loop** | Explore a fully provisioned AI agent data path: Kong gateway, three MCP-exposed mock APIs, and an Expense Agent UI — all pre-wired by Terraform. Trace every request hop and observe the agent's decisions in real time. | 7 |
| [Lab 2](workshops/lab2-auth-tool-access/) | **Auth & Tool Access Control** | Add key authentication and ACL scoping to tool routes so Kong controls exactly which tools the agent is allowed to call. Create a named consumer for the agent and observe enforcement. | 7 |
| [Lab 3](workshops/lab3-llm-governance/) | **LLM Governance** | Route all LLM calls through Kong's AI Gateway. Apply rate limiting, multi-provider failover, prompt guardrails, and semantic caching — without changing a line of agent code. | 8 |
| [Lab 4](workshops/lab4-kafka-events/) *(optional)* | **Event Trail** | Attach Kong's Kafka Upstream plugin to the decision route. Every agent decision becomes a Kafka event, giving you an immutable audit trail and the foundation for event-driven governance. | 6 |

---

## Repository Layout

```
kong-data-path-workshop/
├── agent/                              # Volcano TypeScript agent + web UI
│   ├── src/
│   │   ├── index.ts                    # CLI entrypoint — reads env, runs agent once
│   │   ├── agent.ts                    # Volcano agent definition & run loop
│   │   ├── server.ts                   # Express API server (POST /api/run, static UI)
│   │   ├── ui.ts                       # Terminal UI helper
│   │   └── config.ts                   # Kong endpoint configuration
│   ├── public/                         # Expense Agent web UI (served by server.ts)
│   │   ├── index.html                  # Dashboard — config sidebar + expense runner
│   │   ├── app.js                      # Frontend logic (ES module, no build step)
│   │   └── style.css                   # Kong-branded dark theme
│   ├── k8s/                            # Kubernetes manifests
│   │   ├── namespace.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml                # Kong IC annotations (update host before use)
│   │   ├── configmap.yaml
│   │   └── kustomization.yaml
│   ├── Dockerfile                      # Multi-stage build (tsc → production node)
│   ├── .dockerignore
│   ├── package.json
│   ├── tsconfig.json
│   └── .env.example
│
├── mock-apis/                          # OpenAPI specs for the three mock back-ends
│   ├── expense-service/                # POST /approve  POST /reject  POST /escalate
│   │   └── openapi.yaml
│   ├── hr-service/                     # GET /employees/:id  GET /departments/:id
│   │   └── openapi.yaml
│   └── policy-service/                 # GET /policy  POST /evaluate
│       └── openapi.yaml
│
├── workshops/
│   ├── resources/
│   │   └── trainingportal.yaml         # Educates TrainingPortal CRD (lists all labs)
│   │
│   ├── lab1-agent-loop/
│   │   ├── resources/workshop.yaml     # Educates Workshop CRD
│   │   └── workshop/
│   │       ├── config.yaml             # Page order & nav
│   │       ├── content/                # Markdown pages (00–07)
│   │       └── static/images/
│   │
│   ├── lab2-auth-tool-access/
│   │   ├── resources/workshop.yaml
│   │   └── workshop/
│   │       ├── config.yaml
│   │       ├── content/                # Markdown pages (00–07)
│   │       └── static/images/
│   │
│   ├── lab3-llm-governance/
│   │   ├── resources/workshop.yaml
│   │   └── workshop/
│   │       ├── config.yaml
│   │       ├── content/                # Markdown pages (00–07)
│   │       └── static/images/
│   │
│   └── lab4-kafka-events/
│       ├── resources/workshop.yaml
│       └── workshop/
│           ├── config.yaml
│           ├── content/                # Markdown pages (00–05)
│           └── static/images/
│
├── decK/
│   ├── lab1-agent-loop/
│   │   └── kong.yaml                   # MCP proxy + AI route — base state
│   ├── lab2-auth-tool-access/
│   │   └── kong.yaml                   # Adds key-auth + ACL plugins
│   ├── lab3-llm-governance/
│   │   └── kong.yaml                   # Adds AI Gateway, rate-limiting, guardrails
│   └── lab4-kafka-events/
│       └── kong.yaml                   # Adds Kafka Upstream plugin on decision route
│
├── terraform/
│   ├── gke-educates/                   # Provision GKE cluster for Educates
│   │   ├── main.tf
│   │   └── terraform.tfvars.example
│   │
│   └── kong-serverless-gateways/       # Provision per-student Konnect environments
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── provider.tf
│       └── terraform.tfvars.example
│
└── docker-compose.yml                  # Local dev: agent (optional) + Kafka (Lab 4)
```

---

## How the Mock APIs Work

The three back-end services are **not running processes**. Kong's **Mocking plugin** reads the `example` fields directly from each OpenAPI spec in `mock-apis/` and returns them as HTTP responses — no upstream is ever contacted. The AI MCP Proxy Plugin (`conversion-listener` mode) then translates those REST responses into MCP tool results for the agent.

This means:

- **Lab 1–3**: No services need to be started. Kong handles all mock responses.
- **Lab 4**: Only Kafka needs a running process (see below).

---

## Prerequisites

### For Students

Everything needed to run each lab is pre-provisioned by Terraform and injected into the Educates session. Students only need:

- A browser (to access the Educates workshop portal and Expense Agent UI)
- An **OpenAI API key** (`sk-…`) — the one thing not pre-provisioned

### For Instructors

Before running a session you need to provision one isolated Konnect environment per student. The [`terraform/kong-serverless-gateways/`](terraform/kong-serverless-gateways/) module handles this. Each student environment includes:

- A Konnect Serverless Gateway with MCP routes and the Expense Agent pre-deployed
- An AI Gateway route for LLM proxying (Labs 3+)
- A Konnect Config Store (prefix `agent`) for upstream secret injection
- A pre-seeded consumer (`expense-agent`) for Labs 2+

**Quick start:**

```bash
cd terraform/kong-serverless-gateways
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set konnect_personal_access_token and student_count (system account created automatically)
terraform init
terraform plan
terraform apply
```

After `apply`, extract and distribute per-student values:

```bash
terraform output serverless_gateway_urls    # → $PROXY per student
terraform output llm_route_urls             # → $LLM_PROXY per student
terraform output agent_api_keys             # → $AGENT_API_KEY per student (Lab 2+)
terraform output kafka_bootstrap_servers    # → $KAFKA_BOOTSTRAP (Lab 4 only)
```

The Educates cluster is provisioned separately by [`terraform/gke-educates/`](terraform/gke-educates/). See its README for setup instructions.

---

## Publishing & Deploying the Workshop Content

### Local Development

Run the full Educates workshop stack on your laptop using a local Kind cluster.

#### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Educates CLI](https://docs.educates.dev/en/stable/installation-guides/cli-based-installation.html)

#### 1. Create the local cluster

```bash
educates create-cluster --domain 127-0-0-1.sslip.io
```

#### 2. Publish and deploy a lab

```bash
# Lab 1
educates publish-workshop --name lab-data-path-agent-loop
educates deploy-workshop --file workshops/lab1-agent-loop/resources/workshop.yaml

# Lab 2
educates publish-workshop --name lab-data-path-auth
educates deploy-workshop --file workshops/lab2-auth-tool-access/resources/workshop.yaml

# Lab 3
educates publish-workshop --name lab-data-path-llm-governance
educates deploy-workshop --file workshops/lab3-llm-governance/resources/workshop.yaml

# Lab 4 (optional)
educates publish-workshop --name lab-data-path-kafka
educates deploy-workshop --file workshops/lab4-kafka-events/resources/workshop.yaml
```

#### 3. List workshops and open the training portal

```bash
educates list-workshops
educates browse-workshops
```

If prompted for credentials:

```bash
educates view-credentials
```

#### 4. Tear down

```bash
educates delete-cluster
```

---

## Running Kafka Locally (Lab 4 only)

Labs 1–3 need no running services — Kong's Mocking plugin handles all mock API responses. For Lab 4, start Kafka locally with:

```bash
docker compose --profile kafka up -d
```

This brings up a single-node Kafka broker on port `9092` and a Kafka UI on `http://localhost:8080`.

To optionally run the agent as a container (outside Educates):

```bash
docker compose --profile agent up -d
```

---

## Running the Agent Locally (outside Educates)

If you want to run the Expense Agent outside of an Educates session:

```bash
cd agent
cp .env.example .env
# Edit .env — set PROXY, OPENAI_API_KEY, and optionally AGENT_API_KEY / LLM_PROXY
npm install
npm run dev          # starts the Express server + UI on http://localhost:3000
```

Or run as a one-shot CLI:

```bash
npm run dev:cli -- "Team lunch for 8 people — $320, receipt attached"
```

---

## Containerising the Agent

A multi-stage `Dockerfile` is included in `agent/`. To build and push:

```bash
docker build -t expense-agent:latest ./agent
docker tag expense-agent:latest <your-registry>/expense-agent:latest
docker push <your-registry>/expense-agent:latest
```

Kubernetes manifests live in `agent/k8s/`. Deploy with Kustomize:

```bash
# Update the image tag in agent/k8s/kustomization.yaml first
kubectl apply -k agent/k8s/
```

Update the `host` field in `agent/k8s/ingress.yaml` to match your cluster's domain before applying.

---

## decK Configs

Each lab directory under `decK/` contains a `kong.yaml` representing the full Kong state for that lab. They are cumulative — Lab 2's config is a superset of Lab 1's, and so on. Sync a config with:

```bash
deck gateway sync decK/lab1-agent-loop/kong.yaml \
  --konnect-token $KONNECT_TOKEN \
  --konnect-control-plane-name $CP_NAME
```

Before syncing, the following placeholders must be replaced (or use `--env-var`):

| Placeholder | Description |
|-------------|-------------|
| `$PROXY_HOST` | Public hostname of the student's Kong Gateway proxy |
| `$LLM_UPSTREAM` | LLM provider base URL (e.g. `api.openai.com`) |
| `$KAFKA_BOOTSTRAP` | Kafka broker address (Lab 4 only) |

---

## Environment Variables Reference

Variables surfaced in the Educates session (set by the instructor at deploy time):

| Variable | Used in | Description |
|----------|---------|-------------|
| `PROXY` | All labs | Public URL of the student's Kong Gateway proxy |
| `AGENT_URL` | All labs | URL of the Expense Agent UI tab |
| `LLM_PROXY` | Lab 3 | Kong AI Gateway route URL for LLM calls |
| `AGENT_API_KEY` | Lab 2, 3, 4 | API key for the `expense-agent` consumer |
| `KONNECT_TOKEN` | Lab 2, 3 | Konnect PAT for Config Store access |
| `KAFKA_BOOTSTRAP` | Lab 4 | Kafka broker bootstrap server address |

---

## Relationship to the Kong MCP Workshop

This workshop is a companion series to the [Kong MCP Workshop](https://github.com/Kong/kong-mcp-workshop). Lab 1 here deliberately reuses the AI MCP Proxy Plugin in `conversion-listener` mode (identical to MCP Workshop Lab 1), so participants who have completed that series will recognize the tool-exposure pattern and can focus on the new concept: governing an autonomous agent's full reasoning loop rather than a single tool proxy.

| Kong MCP Workshop | Kong Data Path Workshop |
|-------------------|------------------------|
| Lab 1 — Conversion Listener | Lab 1 — Agent Loop *(builds on the same plugin)* |
| Lab 2 — Passthrough + Auth | Lab 2 — Auth & Tool Access Control |
| Lab 3 — Registry & Governance | Lab 3 — LLM Governance *(extends to the LLM hop)* |
| *(not covered)* | Lab 4 — Kafka Event Trail *(optional)* |

---

## Contributing

Lab content lives in `workshop/content/*.md` for each lab. Page order is controlled by `workshop/config.yaml` — add the step name to the `steps` list and create the matching `.md` file with a `title:` frontmatter field.

Screenshot assets live in each lab's `workshop/static/images/` directory. Content pages reference them as `{{<baseurl>}}/images/filename.png`. Keep filenames stable so existing references don't break.
