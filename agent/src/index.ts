/**
 * CLI entry point — reads config from environment variables and evaluates
 * a single expense passed on the command line (or a default example).
 *
 * Usage:
 *   npm run dev
 *   npm run dev -- "Alice (emp-001) wants to expense $150 for a team lunch"
 *   npm run dev -- "Bob (emp-002) is submitting $2500 for a conference trip"
 */

import "dotenv/config";
import { evaluateExpense, type AgentRunConfig } from "./agent.js";

function required(name: string): string {
  const val = process.env[name];
  if (!val) throw new Error(`Missing env var: ${name}. Copy .env.example → .env`);
  return val;
}

const cfg: AgentRunConfig = {
  proxy:        required("PROXY"),
  openaiApiKey: required("OPENAI_API_KEY"),
  llmProxy:     process.env.LLM_PROXY,
  llmModel:     process.env.LLM_MODEL,
  agentApiKey:  process.env.AGENT_API_KEY,
};

const DEFAULT_EXPENSE =
  'Alice (emp-001) is submitting an expense of $150 for "Team lunch".';

const expenseInput = process.argv.slice(2).join(" ") || DEFAULT_EXPENSE;

console.log("─".repeat(60));
console.log("Expense input:");
console.log(expenseInput);
console.log("─".repeat(60));
console.log();

try {
  const result = await evaluateExpense(expenseInput, cfg);
  console.log("Agent decision:");
  console.log(result);
} catch (err) {
  console.error("Agent error:", err);
  process.exit(1);
}
