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

function optional(name: string): string | undefined {
  return process.env[name] || undefined;
}

const cfg: AgentRunConfig = {
  proxy:        optional("PROXY"),
  openaiApiKey: optional("OPENAI_API_KEY"),
  llmProxy:     optional("LLM_PROXY"),
  llmModel:     optional("LLM_MODEL"),
  agentApiKey:  optional("AGENT_API_KEY"),
};

// Check if we have minimum required configuration
if (!cfg.openaiApiKey) {
  console.error("Warning: No OPENAI_API_KEY provided. Agent will not be able to make LLM calls.");
}
if (!cfg.proxy) {
  console.log("Notice: No PROXY provided. Running in fallback mode without MCP servers.");
}

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
