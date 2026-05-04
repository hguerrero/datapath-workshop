/**
 * Expense Approval Agent — browser UI
 *
 * This module owns all DOM interaction. It talks to the Express backend at
 * /api/run and /api/ping. No inline event handlers anywhere — all listeners
 * are registered here so behaviour is easy to trace in DevTools.
 */

// ── Storage helpers ──────────────────────────────────────────────────────────
const STORAGE_KEY = "expense-agent-config";

/** @returns {Record<string,string>} */
function loadConfig() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY) ?? "{}");
  } catch {
    return {};
  }
}

/** @param {Record<string,string>} cfg */
function saveConfig(cfg) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(cfg));
}

function clearConfig() {
  localStorage.removeItem(STORAGE_KEY);
}

// ── DOM refs ─────────────────────────────────────────────────────────────────
const $ = (id) => document.getElementById(id);

const proxyEl        = $("proxy");
const agentApiKeyEl  = $("agentApiKey");
const openaiKeyEl    = $("openaiApiKey");
const llmProxyEl     = $("llmProxy");
const llmModelEl     = $("llmModel");
const expenseEl      = $("expenseInput");

const btnRun         = $("btn-run");
const btnSave        = $("btn-save");
const btnClear       = $("btn-clear");

const statusBar      = $("status-bar");
const statusDot      = $("status-dot");
const statusText     = $("status-text");

const resultBox      = $("result-box");
const resultPre      = $("result-text");
const decisionBadge  = $("decision-badge");

// ── Populate form from localStorage ──────────────────────────────────────────
(function restoreForm() {
  const cfg = loadConfig();
  if (cfg.proxy)        proxyEl.value       = cfg.proxy;
  if (cfg.agentApiKey)  agentApiKeyEl.value  = cfg.agentApiKey;
  if (cfg.openaiApiKey) openaiKeyEl.value    = cfg.openaiApiKey;
  if (cfg.llmProxy)     llmProxyEl.value     = cfg.llmProxy;
  if (cfg.llmModel)     llmModelEl.value     = cfg.llmModel;
})();

// ── Status helpers ────────────────────────────────────────────────────────────
/** @param {"running"|"success"|"error"} state @param {string} msg */
function setStatus(state, msg) {
  statusBar.classList.remove("hidden");
  statusDot.className = `status-dot ${state}`;
  statusText.textContent = msg;
}

function hideStatus() {
  statusBar.classList.add("hidden");
}

// ── Decision detection ────────────────────────────────────────────────────────
/** @param {string} text @returns {"approve"|"reject"|"escalate"|"unknown"} */
function detectDecision(text) {
  const t = text.toUpperCase();
  if (t.includes("APPROVE")) return "approve";
  if (t.includes("REJECT"))  return "reject";
  if (t.includes("ESCALATE")) return "escalate";
  return "unknown";
}

const BADGE_LABELS = {
  approve:  "✓ Approved",
  reject:   "✗ Rejected",
  escalate: "⚠ Escalated",
  unknown:  "···",
};

// ── Show result ───────────────────────────────────────────────────────────────
/** @param {string} text */
function showResult(text) {
  const decision = detectDecision(text);
  decisionBadge.textContent = BADGE_LABELS[decision];
  decisionBadge.className   = `decision-badge ${decision}`;
  resultPre.textContent     = text;
  resultBox.classList.remove("hidden");
}

function hideResult() {
  resultBox.classList.add("hidden");
}

// ── Example chips ─────────────────────────────────────────────────────────────
document.querySelectorAll(".chip").forEach((chip) => {
  chip.addEventListener("click", () => {
    expenseEl.value = chip.dataset.example ?? "";
    // Highlight active chip
    document.querySelectorAll(".chip").forEach((c) => c.classList.remove("active"));
    chip.classList.add("active");
    // Clear any previous result when picking a new example
    hideResult();
    hideStatus();
  });
});

// ── Button: Save config ───────────────────────────────────────────────────────
btnSave.addEventListener("click", () => {
  const cfg = {
    proxy:        proxyEl.value.trim(),
    agentApiKey:  agentApiKeyEl.value.trim(),
    openaiApiKey: openaiKeyEl.value.trim(),
    llmProxy:     llmProxyEl.value.trim(),
    llmModel:     llmModelEl.value.trim(),
  };
  saveConfig(cfg);
  btnSave.textContent = "Saved ✓";
  setTimeout(() => { btnSave.textContent = "Save Config"; }, 1500);
});

// ── Button: Clear saved ───────────────────────────────────────────────────────
btnClear.addEventListener("click", () => {
  clearConfig();
  proxyEl.value       = "";
  agentApiKeyEl.value  = "";
  openaiKeyEl.value    = "";
  llmProxyEl.value     = "";
  llmModelEl.value     = "";
  btnClear.textContent = "Cleared ✓";
  setTimeout(() => { btnClear.textContent = "Clear Saved"; }, 1500);
});

// Deactivate chips when user edits the textarea manually
expenseEl.addEventListener("input", () => {
  document.querySelectorAll(".chip").forEach((c) => c.classList.remove("active"));
});

// ── Button: Run agent ─────────────────────────────────────────────────────────
btnRun.addEventListener("click", async () => {
  const proxy        = proxyEl.value.trim();
  const openaiApiKey = openaiKeyEl.value.trim();
  const expenseInput = expenseEl.value.trim();

  if (!proxy) {
    setStatus("error", "Proxy URL is required.");
    return;
  }
  if (!openaiApiKey) {
    setStatus("error", "OpenAI API Key is required.");
    return;
  }
  if (!expenseInput) {
    setStatus("error", "Please describe the expense.");
    return;
  }

  hideResult();
  setStatus("running", "Agent is evaluating the expense…");
  btnRun.disabled = true;

  const payload = {
    proxy,
    openaiApiKey,
    expenseInput,
    agentApiKey:  agentApiKeyEl.value.trim()  || undefined,
    llmProxy:     llmProxyEl.value.trim()     || undefined,
    llmModel:     llmModelEl.value.trim()     || undefined,
  };

  try {
    const res  = await fetch("/api/run", {
      method:  "POST",
      headers: { "Content-Type": "application/json" },
      body:    JSON.stringify(payload),
    });

    const data = await res.json();

    if (!res.ok) {
      setStatus("error", `Server error: ${data.error ?? res.statusText}`);
    } else {
      setStatus("success", "Done.");
      showResult(data.result || "(no output returned by agent)");
    }
  } catch (err) {
    setStatus("error", `Network error: ${err.message}`);
  } finally {
    btnRun.disabled = false;
  }
});
