/**
 * UI server — serves a Kong-branded single-page interface for the expense
 * approval agent. No framework needed: just Node's built-in http module.
 *
 * Usage:  npm run ui
 * Then open: http://localhost:3333
 *
 * All configuration (proxy URL, API keys, model) is entered in the browser
 * and persisted to localStorage — no .env file required.
 */

import { createServer, type IncomingMessage, type ServerResponse } from "http";
import { evaluateExpense, type AgentRunConfig } from "./agent.js";

const PORT = process.env.PORT ? parseInt(process.env.PORT) : 3333;

// ── Inline UI ─────────────────────────────────────────────────────────────────
const HTML = /* html */ `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Kong · Expense Approval Agent</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Funnel+Sans:wght@300;400;800&family=Roboto+Mono:wght@400;700&display=swap');

  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  :root {
    --bg:      #000F06;
    --lime:    #CCFF00;
    --bay:     #B7BDB5;
    --surf:    #0D1F10;
    --brd:     #2D3B2F;
    --muted:   #4A4D49;
    --font:    'Funnel Sans', system-ui, sans-serif;
    --mono:    'Roboto Mono', monospace;
    --radius:  6px;
  }

  body {
    font-family: var(--font);
    background: var(--bg);
    color: #fff;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }

  /* Header */
  header {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 13px 22px;
    border-bottom: 1px solid var(--brd);
    flex-shrink: 0;
  }
  .logo { font-size: 15px; font-weight: 800; color: var(--lime); letter-spacing: -0.3px; }
  .logo span { color: var(--bay); font-weight: 300; }
  .badge {
    font-family: var(--mono);
    font-size: 9px;
    font-weight: 700;
    color: var(--bg);
    background: var(--lime);
    padding: 2px 8px;
    border-radius: 20px;
    letter-spacing: 0.5px;
  }

  /* Two-column layout */
  main {
    flex: 1;
    display: grid;
    grid-template-columns: 260px 1fr;
    overflow: hidden;
  }

  /* Config sidebar */
  aside {
    display: flex;
    flex-direction: column;
    gap: 16px;
    padding: 20px 18px;
    border-right: 1px solid var(--brd);
    background: #050f07;
    overflow-y: auto;
  }

  .sec-label {
    font-family: var(--mono);
    font-size: 9px;
    letter-spacing: 1.5px;
    color: var(--lime);
    text-transform: uppercase;
    margin-bottom: 12px;
  }

  .field { display: flex; flex-direction: column; gap: 5px; }

  label {
    font-family: var(--mono);
    font-size: 10px;
    color: var(--bay);
    letter-spacing: 0.3px;
  }
  label .hint { color: var(--muted); font-size: 9px; }

  input {
    background: var(--surf);
    border: 1px solid var(--brd);
    border-radius: var(--radius);
    color: #fff;
    font-family: var(--mono);
    font-size: 11.5px;
    padding: 7px 9px;
    outline: none;
    transition: border-color 0.15s;
    width: 100%;
  }
  input:focus { border-color: var(--lime); }
  input::placeholder { color: var(--muted); }

  .save-btn {
    width: 100%;
    padding: 7px 0;
    background: transparent;
    border: 1px solid var(--brd);
    border-radius: var(--radius);
    color: var(--bay);
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: 0.5px;
    cursor: pointer;
    transition: border-color 0.15s, color 0.15s;
    margin-top: 2px;
  }
  .save-btn:hover { border-color: var(--lime); color: var(--lime); }

  /* Run panel */
  section {
    display: flex;
    flex-direction: column;
    gap: 18px;
    padding: 20px 26px;
    overflow-y: auto;
  }

  textarea {
    background: var(--surf);
    border: 1px solid var(--brd);
    border-radius: var(--radius);
    color: #fff;
    font-family: var(--font);
    font-size: 13.5px;
    line-height: 1.6;
    padding: 12px 14px;
    resize: vertical;
    min-height: 90px;
    outline: none;
    transition: border-color 0.15s;
    width: 100%;
  }
  textarea:focus { border-color: var(--lime); }

  /* Example chips */
  .chips { display: flex; flex-direction: column; gap: 5px; }
  .chip {
    background: transparent;
    border: 1px solid var(--brd);
    border-radius: var(--radius);
    color: var(--bay);
    font-family: var(--font);
    font-size: 11.5px;
    padding: 6px 10px;
    text-align: left;
    cursor: pointer;
    transition: border-color 0.15s, color 0.15s;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .chip:hover { border-color: var(--lime); color: var(--lime); }

  /* Run button */
  .run-btn {
    align-self: flex-start;
    padding: 9px 26px;
    background: var(--lime);
    border: none;
    border-radius: var(--radius);
    color: var(--bg);
    font-family: var(--font);
    font-size: 13.5px;
    font-weight: 800;
    cursor: pointer;
    transition: opacity 0.15s;
  }
  .run-btn:hover   { opacity: 0.88; }
  .run-btn:active  { opacity: 0.75; }
  .run-btn:disabled { opacity: 0.35; cursor: not-allowed; }

  /* Output */
  .out-header { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
  .out-header .sec-label { margin-bottom: 0; }
  .dot {
    width: 7px; height: 7px;
    border-radius: 50%;
    background: var(--brd);
    transition: background 0.2s;
    flex-shrink: 0;
  }
  .dot.running { background: var(--lime); animation: pulse 1s infinite; }
  .dot.done    { background: #00cc66; }
  .dot.error   { background: #ff4444; }

  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50%       { opacity: 0.25; }
  }

  pre {
    background: var(--surf);
    border: 1px solid var(--brd);
    border-radius: var(--radius);
    color: var(--lime);
    font-family: var(--mono);
    font-size: 12px;
    line-height: 1.75;
    padding: 14px 16px;
    white-space: pre-wrap;
    word-break: break-word;
    min-height: 200px;
    flex: 1;
  }
  pre.placeholder { color: var(--muted); }
  pre.err         { color: #ff6b6b; }
</style>
</head>
<body>

<header>
  <div class="logo">KONG <span>Expense Approval Agent</span></div>
  <div class="badge">WORKSHOP</div>
</header>

<main>

  <!-- Config sidebar -->
  <aside>
    <div>
      <div class="sec-label">Configuration</div>

      <div class="field">
        <label>GATEWAY PROXY URL</label>
        <input id="proxy" type="url" placeholder="https://…konghq.com">
      </div>
    </div>

    <div class="field">
      <label>OPENAI API KEY</label>
      <input id="openaiKey" type="password" placeholder="sk-…">
    </div>

    <div class="field">
      <label>
        LLM PROXY
        <span class="hint">&nbsp;Lab 3 → use $PROXY/llm</span>
      </label>
      <input id="llmProxy" type="url" placeholder="https://api.openai.com">
    </div>

    <div class="field">
      <label>
        AGENT API KEY
        <span class="hint">&nbsp;empty for Lab 1</span>
      </label>
      <input id="agentKey" type="password" placeholder="(Lab 2+)">
    </div>

    <div class="field">
      <label>LLM MODEL</label>
      <input id="model" type="text" placeholder="gpt-4o-mini">
    </div>

    <button type="button" class="save-btn" id="saveBtn">SAVE TO BROWSER</button>
  </aside>

  <!-- Run panel -->
  <section>

    <div>
      <div class="sec-label">Expense to Evaluate</div>
      <textarea id="expense" rows="4">Alice (emp-001) is submitting an expense of $150 for "Team lunch".</textarea>
    </div>

    <div>
      <div class="sec-label" style="margin-bottom:8px">Quick Examples</div>
      <div class="chips">
        <button type="button" class="chip"
          data-v='Alice (emp-001) is submitting an expense of $150 for "Team lunch".'>
          ✅  $150 · Team lunch · Alice (emp-001)
        </button>
        <button type="button" class="chip"
          data-v="Bob (emp-002) is submitting $2500 for cloud conference sponsorship.">
          ⬆️  $2500 · Conference sponsorship · Bob (emp-002) — escalation expected
        </button>
        <button type="button" class="chip"
          data-v='Clara (emp-003) is submitting $80 for team drinks at a casino.'>
          ❌  $80 · Casino drinks · Clara (emp-003) — rejection expected
        </button>
      </div>
    </div>

    <button type="button" class="run-btn" id="runBtn">
      Evaluate Expense
    </button>

    <div style="display:flex;flex-direction:column;flex:1">
      <div class="out-header">
        <div class="sec-label">Agent Decision</div>
        <div class="dot" id="dot"></div>
      </div>
      <pre id="output" class="placeholder">Agent output will appear here…</pre>
    </div>

  </section>
</main>

<script>
// Ensure the initialization runs even if there are timing issues
function initializeUI() {
  var KEYS = ['proxy', 'openaiKey', 'llmProxy', 'agentKey', 'model'];

  // ── Restore saved config ──────────────────────────────────────────────────
  KEYS.forEach(function (id) {
    var v = localStorage.getItem('kong_' + id);
    if (v) {
      var element = document.getElementById(id);
      if (element) element.value = v;
    }
  });

  // ── Save button ───────────────────────────────────────────────────────────
  var saveBtn = document.getElementById('saveBtn');
  if (saveBtn) {
    // Remove any existing listeners to prevent duplicates
    saveBtn.replaceWith(saveBtn.cloneNode(true));
    saveBtn = document.getElementById('saveBtn');
    
    saveBtn.addEventListener('click', function () {
      KEYS.forEach(function (id) {
        localStorage.setItem('kong_' + id, document.getElementById(id).value);
      });
      this.textContent = 'SAVED';
      var btn = this;
      setTimeout(function () { btn.textContent = 'SAVE TO BROWSER'; }, 1600);
    });
  }

  // ── Example chips ─────────────────────────────────────────────────────────
  document.querySelectorAll('.chip').forEach(function (chip) {
    // Remove any existing listeners to prevent duplicates
    var newChip = chip.cloneNode(true);
    chip.parentNode.replaceChild(newChip, chip);
    
    newChip.addEventListener('click', function () {
      var expenseEl = document.getElementById('expense');
      if (expenseEl) expenseEl.value = this.dataset.v;
    });
  });

  // ── Run button ────────────────────────────────────────────────────────────
  var runBtn = document.getElementById('runBtn');
  if (runBtn) {
    // Remove any existing listeners to prevent duplicates
    runBtn.replaceWith(runBtn.cloneNode(true));
    runBtn = document.getElementById('runBtn');
    
    runBtn.addEventListener('click', runAgent);
  }

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) runAgent();
  });

  async function runAgent() {
    var proxy     = document.getElementById('proxy').value.trim();
    var openaiKey = document.getElementById('openaiKey').value.trim();
    var llmProxy  = document.getElementById('llmProxy').value.trim() || undefined;
    var agentKey  = document.getElementById('agentKey').value.trim() || undefined;
    var model     = document.getElementById('model').value.trim() || undefined;
    var expense   = document.getElementById('expense').value.trim();

    if (!proxy || !openaiKey) {
      setOutput('Set Gateway Proxy URL and OpenAI API Key first.', 'err');
      return;
    }
    if (!expense) {
      setOutput('Enter an expense to evaluate.', 'err');
      return;
    }

    var runBtn = document.getElementById('runBtn');
    if (runBtn) {
      runBtn.disabled = true;
      runBtn.textContent = 'Running…';
    }
    setDot('running');
    setOutput('Calling agent…', '');

    try {
      var res = await fetch('/run', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          expense: expense,
          config: {
            proxy: proxy,
            openaiApiKey: openaiKey,
            llmProxy: llmProxy,
            llmModel: model,
            agentApiKey: agentKey
          }
        })
      });
      var data = await res.json();
      if (data.error) {
        setOutput('ERROR:\n' + data.error, 'err');
        setDot('error');
      } else {
        setOutput(data.result, '');
        setDot('done');
      }
    } catch (e) {
      setOutput('Network error: ' + e.message, 'err');
      setDot('error');
    } finally {
      if (runBtn) {
        runBtn.disabled = false;
        runBtn.textContent = 'Evaluate Expense';
      }
    }
  }

  function setOutput(text, cls) {
    var el = document.getElementById('output');
    if (el) {
      el.textContent = text;
      el.className = cls || '';
    }
  }

  function setDot(state) {
    var dotEl = document.getElementById('dot');
    if (dotEl) dotEl.className = 'dot ' + state;
  }

  // Make runAgent available globally for debugging
  window.runAgent = runAgent;
}

// Multiple ways to ensure initialization happens
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeUI);
} else {
  // Document already loaded
  initializeUI();
}

// Fallback initialization after a short delay
setTimeout(function() {
  if (!window.runAgent) {
    console.log('Fallback UI initialization');
    initializeUI();
  }
}, 100);
</script>
</body>
</html>`;

// ── HTTP server ───────────────────────────────────────────────────────────────

function readBody(req: IncomingMessage): Promise<string> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    req.on("data", (c: Buffer) => chunks.push(c));
    req.on("end",  () => resolve(Buffer.concat(chunks).toString("utf8")));
    req.on("error", reject);
  });
}

function send(res: ServerResponse, status: number, body: string, type = "text/plain") {
  res.writeHead(status, {
    "Content-Type": type,
    "Content-Length": Buffer.byteLength(body),
  });
  res.end(body);
}

const server = createServer(async (req, res) => {
  if (req.method === "GET" && req.url === "/") {
    return send(res, 200, HTML, "text/html; charset=utf-8");
  }

  if (req.method === "POST" && req.url === "/run") {
    let bodyData: { expense: string; config: AgentRunConfig } | undefined;
    
    try {
      bodyData = JSON.parse(await readBody(req)) as {
        expense: string;
        config: AgentRunConfig;
      };
      const result = await evaluateExpense(bodyData.expense, bodyData.config);
      return send(res, 200, JSON.stringify({ result }), "application/json");
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : String(err);
      
      // Provide more helpful error messages for common issues
      let helpfulMessage = message;
      if (message.includes("fetch failed") || message.includes("ENOTFOUND") || message.includes("ECONNREFUSED")) {
        helpfulMessage = `Network error: Could not connect to Kong proxy at ${bodyData?.config?.proxy || 'unknown URL'}. 

Please ensure:
1. The Kong proxy URL is correct and accessible
2. The MCP services are running at /mcp/expense, /mcp/hr, and /mcp/policy
3. Your network connection is working

Original error: ${message}`;
      } else if (message.includes("401") || message.includes("Unauthorized")) {
        helpfulMessage = `Authentication error: Invalid API key or unauthorized access.

Please check:
1. OpenAI API key is valid and has sufficient quota
2. Agent API key is correct (if using Lab 2+)

Original error: ${message}`;
      }
      
      console.error("Agent evaluation error:", err);
      return send(res, 500, JSON.stringify({ error: helpfulMessage }), "application/json");
    }
  }

  send(res, 404, "Not found");
});

server.listen(PORT, () => {
  console.log(`\n  Kong Expense Agent UI`);
  console.log(`  ─────────────────────`);
  console.log(`  http://localhost:${PORT}`);
  console.log();
});
