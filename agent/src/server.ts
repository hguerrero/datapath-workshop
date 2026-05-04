/**
 * Express API server for the Expense Approval Agent UI.
 *
 * Serves the static frontend from ../public/ and exposes:
 *   POST /api/run   — evaluate an expense via evaluateExpense()
 *   GET  /api/ping  — health check
 *
 * Run with:
 *   npm run dev:server
 *   npm run dev          (alias)
 */

import express from "express";
import cors from "cors";
import { fileURLToPath } from "url";
import { dirname, join } from "path";
import { evaluateExpense, type AgentRunConfig } from "./agent.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const PUBLIC_DIR = join(__dirname, "..", "public");
const PORT = Number(process.env.PORT ?? 3000);

const app = express();

// ── Middleware ─────────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.static(PUBLIC_DIR));

// ── Health check ───────────────────────────────────────────────────────────
app.get("/api/ping", (_req, res) => {
  res.json({ ok: true, ts: new Date().toISOString() });
});

// ── Run agent ──────────────────────────────────────────────────────────────
app.post("/api/run", async (req, res) => {
  const {
    proxy,
    openaiApiKey,
    llmProxy,
    llmModel,
    agentApiKey,
    expenseInput,
  } = req.body as {
    proxy: string;
    openaiApiKey: string;
    llmProxy?: string;
    llmModel?: string;
    agentApiKey?: string;
    expenseInput: string;
  };

  if (!proxy || !openaiApiKey || !expenseInput) {
    res.status(400).json({
      error: "Missing required fields: proxy, openaiApiKey, expenseInput",
    });
    return;
  }

  const cfg: AgentRunConfig = {
    proxy,
    openaiApiKey,
    llmProxy,
    llmModel,
    agentApiKey,
  };

  try {
    const result = await evaluateExpense(expenseInput, cfg);
    console.log(`[/api/run] result (${result.length} chars):`, result.slice(0, 120) || "(empty)");
    res.json({ result });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    res.status(500).json({ error: message });
  }
});

// ── Catch-all → SPA fallback (Express 5 wildcard syntax) ──────────────────
app.get("/{*path}", (_req, res) => {
  res.sendFile(join(PUBLIC_DIR, "index.html"));
});

// ── Start ──────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\nExpense Agent UI  →  http://localhost:${PORT}\n`);
});
