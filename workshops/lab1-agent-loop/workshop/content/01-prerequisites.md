---
title: Prerequisites
---

## Before You Start

### What you need

- **Konnect account** — your instructor has provisioned a Serverless Gateway for you.
  The gateway URL is available in this terminal as `$PROXY`.
- **Node.js 20+** — verify with `node --version`
- **npm** — verify with `npm --version`
- **curl**
- **An OpenAI API key** — you will set this in a `.env` file in the next step.

Check your gateway is reachable:

```bash
curl -s $PROXY/
```

You should see a Kong 404 — no routes configured yet. That's expected.

### Clone the workshop repo

```terminal:execute
command: git clone https://github.com/Kong/kong-data-path-workshop.git && cd kong-data-path-workshop
```

### Install agent dependencies

```terminal:execute
command: cd agent && npm install
```

### Set up the environment file

```terminal:execute
command: cp .env.example .env
```

Open `.env` and fill in your values. The `PROXY` variable is already set in
your session — you can confirm it with:

```terminal:execute
command: echo $PROXY
```

Paste it into `.env` as the value for `PROXY`. Add your OpenAI API key for
`OPENAI_API_KEY`. Leave `AGENT_API_KEY` empty for now (that's Lab 2).

---

→ Continue to **Start the Mock APIs**
