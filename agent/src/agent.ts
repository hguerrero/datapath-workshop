/**
 * Expense Approval Agent — built with the Volcano Agent SDK.
 *
 * The agent connects to three MCP servers, all sitting behind the Kong
 * Serverless Gateway:
 *
 *   Kong proxy → /mcp/expense  → expense-service  (approve / reject / escalate)
 *   Kong proxy → /mcp/hr       → hr-service        (employee / department lookup)
 *   Kong proxy → /mcp/policy   → policy-service    (policy rules + evaluate)
 *
 * Every outbound call — to the LLM and to every MCP tool — passes through
 * Kong. That's the whole point: Kong is the single control plane for the
 * agent's entire data path.
 *
 * Refer to https://volcano.dev/docs for the full SDK reference.
 * The imports and constructor shape below follow the Volcano SDK conventions;
 * update the import path if the package name differs in your installed version.
 */

import { agent, llmOpenAI, mcp } from "@volcano.dev/agent";
import { config } from "./config.js";

// Build optional auth headers — empty in Lab 1, populated from Lab 2 onward
function authHeaders(): Record<string, string> {
  if (!config.agentApiKey) return {};
  return { apikey: config.agentApiKey };
}

// LLM configuration — in Labs 1–2 this hits the provider directly;
// in Lab 3 you change LLM_PROXY to point at the Kong AI Gateway route
const llm = llmOpenAI({
  baseURL: config.proxy,
  apiKey: config.openaiApiKey,
  model: config.llmModel,
});

/**
 * Declare the three MCP servers the agent can reach.
 * Each one points at a Kong route that fronts one of the mock APIs.
 * Kong's AI MCP Proxy Plugin (conversion-listener mode) translates the
 * REST OpenAPI spec into MCP tools automatically — no upstream changes needed.
 *
 * All three URLs resolve to $PROXY/mcp/* — every tool call passes through Kong.
 */
// const tools = [
//   mcp({
//     url: config.tools.expenseMcpUrl,
//     headers: authHeaders(),
//   }),
//   mcp({
//     url: config.tools.hrMcpUrl,
//     headers: authHeaders(),
//   }),
//   mcp({
//     url: config.tools.policyMcpUrl,
//     headers: authHeaders(),
//   }),
// ];

const instructions = `
You are an expense approval agent for a mid-sized technology company.

Your job is to evaluate expense submissions and reach one of three decisions:
  - APPROVE: the expense is within policy and the employee's spending limit
  - REJECT:  the expense violates policy (prohibited category, missing receipt, etc.)
  - ESCALATE: the expense requires human manager sign-off (high value, restricted category, etc.)

To make a good decision, follow this reasoning process:
1. Call the policy service to retrieve current policy rules.
2. Call the HR service to look up the submitting employee's spending limit and department.
3. Call the policy service to evaluate the expense against policy.
4. Based on the evaluation, call the appropriate expense service tool:
     - approveExpense for approved decisions
     - rejectExpense for rejections
     - escalateExpense for escalations
5. Return the decision and the record ID from the expense service.

Always explain your reasoning briefly. Be concise — one sentence per step.
`.trim();

/**
 * Run the agent for a single expense request.
 *
 * @param expenseInput  Plain-language description of the expense, e.g.:
 *   "Alice (emp-001) is submitting $150 for a team lunch."
 */
export async function evaluateExpense(expenseInput: string): Promise<string> {
  const expenseApprover = agent({
    llm,
    // tools,
    name: "expenser",
    description: "Expense Approval Agent",
    instructions,
  });
  const result = await expenseApprover.then({ prompt: expenseInput }).run();
  return result[0].llmOutput || "";
}
