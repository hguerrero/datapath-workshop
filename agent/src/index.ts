/**
 * Agent entrypoint.
 *
 * Reads an expense from the command line (or uses a hardcoded demo) and
 * prints the agent's decision to stdout.
 *
 * Usage:
 *   npm run dev
 *   npm run dev -- "Alice (emp-001) wants to expense $150 for a team lunch"
 *   npm run dev -- "Bob (emp-002) is submitting $2500 for a conference trip"
 */

import "dotenv/config";
import { evaluateExpense } from "./agent.js";

const DEFAULT_EXPENSE =
  'Alice (emp-001) is submitting an expense of $150 for "Team lunch".';

async function main() {
  const expenseInput = process.argv.slice(2).join(" ") || DEFAULT_EXPENSE;

  console.log("─".repeat(60));
  console.log("Expense input:");
  console.log(expenseInput);
  console.log("─".repeat(60));
  console.log();

  try {
    const result = await evaluateExpense(expenseInput);
    console.log("Agent decision:");
    console.log(result);
  } catch (err) {
    console.error("Agent error:", err);
    process.exit(1);
  }
}

main();
