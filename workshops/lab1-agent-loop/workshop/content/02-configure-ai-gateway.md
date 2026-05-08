---
title: Configure the AI Gateway
---

### Step 1 — In Konnect

In the **Konnect** tab you opened in the previous step, create an AI
Gateway, wire it to OpenAI, and expose it on the path `/llm` — all
through the UI.

```dashboard:open-url
url: https://cloud.konghq.com/login/{{< param training_portal >}}
```

---

### 1 · Log in as Custom Admin

On the login screen you will see a list of workshop demo users. Log in
as **Chris Adams** (Custom Admin).

![Log in as Custom Admin]({{< baseurl >}}/images/01-login-as-custom-admin.png)

---

### 2 · Navigate to AI Gateway

In the left sidebar click **AI Gateway**.

![Select AI Gateway in the sidebar]({{< baseurl >}}/images/02-select-ai-gateway.png)

---

### 3 · Create a new AI Gateway from scratch

Click **New AI Gateway**, then choose **Start from scratch** from the
dropdown.

![New AI Gateway — Start from scratch]({{< baseurl >}}/images/03-click-on-new-gateway-from-scratch.png)

---

### 4 · Fill in the gateway details

Fill in the form as follows, then scroll down to the **Route** section.

| Field | Value |
|-------|-------|
| AI Gateway name | `LLM Gateway` |
| AI Gateway description | `A single point of entry for any LLM` |
| Select gateway | choose your control plane (e.g. `student-01-cp`) |

![New AI Gateway — general information and control plane]({{< baseurl >}}/images/04-new-ai-gateway-details-1.png)

In the **Route** section keep **Basic** selected and set:

| Field | Value |
|-------|-------|
| Path | `/llm` |
| Strip Path | ✓ checked |
| Methods | *(leave blank — all methods allowed)* |
| Host | *(leave blank)* |

Click **Save**.

![New AI Gateway — route path /llm with strip path]({{< baseurl >}}/images/04-new-ai-gateway-details-2.png)

---

### 5 · Connect the LLM

After saving you land on the AI Gateway **Overview** page. The
Quickstart panel shows three steps. Click **Connect LLM →**.

![AI Gateway Overview — click Connect LLM]({{< baseurl >}}/images/05-connect-llm.png)

In the **Connect to LLM** dialog set:

| Field | Value |
|-------|-------|
| LLM Provider | `OpenAI` |
| Enter a model | `gpt-4o-mini` |
| API Key | click **pick a secret from vaults** |

![Connect to LLM — provider and model]({{< baseurl >}}/images/06-connect-to-llm-details-1.png)

In the **Look up Key in Vault** dialog:

| Field | Value |
|-------|-------|
| Vault | select the `ai` vault from the dropdown |
| Secret ID | `llm-api-key-openai` |
| Secret Key | *(leave blank)* |

Click **Use Key**, then click **Save**.

![Look up Key in Vault — select llm-api-key-openai]({{< baseurl >}}/images/06-connect-to-llm-vault.png)

---

### 6 · Copy the proxy URL and test from the terminal

Konnect advances to **Test your setup** and shows a ready-to-run
`curl` command. The URL in that command is your AI Gateway proxy URL —
it looks like `https://…serverless.gateways.konghq.com/llm`.

![Test your setup — copy the proxy URL]({{< baseurl >}}/images/07-click-on-test-to-get-proxy-url.png)

Copy the full proxy **base URL** (everything before `/llm`) and save it
in your terminal:

```terminal:execute
command: |
  export LLM_PROXY_URL=https://PASTE_YOUR_URL_HERE
```

Now run the test call from your terminal:

```terminal:execute
command: |
  curl -s -X POST $LLM_PROXY_URL/llm/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
      "model": "gpt-4o-mini",
      "messages": [{"role": "user", "content": "Reply with one word: ready"}],
      "max_tokens": 5
    }' | jq '.choices[0].message.content'
```

Expected: `"ready"` (or similar). No `Authorization` header was needed —
the `ai-proxy` plugin injected your key from the vault automatically.

If you see `401`, wait 15 seconds for the config to propagate and retry.

---

→ Continue to **Connect the Agent**
