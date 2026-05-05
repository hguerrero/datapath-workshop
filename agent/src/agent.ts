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
 * evaluateExpense() accepts an AgentRunConfig so both the CLI (index.ts) and
 * the UI server (ui.ts) share the same logic without any env var requirement.
 */

import { agent, llmOpenAI, mcp } from "@volcano.dev/agent";

export interface AgentRunConfig {
  proxy?: string;       // optional - if missing, MCP servers won't be used
  openaiApiKey?: string; // optional - if missing, agent won't use LLM
  llmProxy?: string;    // defaults to https://api.openai.com
  llmModel?: string;    // defaults to gpt-4o-mini
  agentApiKey?: string; // leave empty for Lab 1
}

const instructions = `
You are an expense approval agent for a mid-sized technology company.

Your job is to evaluate expense submissions and reach one of three decisions:
  - APPROVE: the expense is within policy and the employee's spending limit
  - REJECT:  the expense violates policy (prohibited category, missing receipt, etc.)
  - ESCALATE: the expense requires human manager sign-off (high value, restricted category, etc.)

Always explain your reasoning briefly. Be concise — one sentence per step.
`.trim();

/**
 * Run the agent for a single expense request.
 *
 * @param expenseInput  Plain-language description of the expense, e.g.:
 *   "Alice (emp-001) is submitting $150 for a team lunch."
 * @param cfg  Runtime configuration — proxy URL, API keys, model selection.
 */
export async function evaluateExpense(
  expenseInput: string,
  cfg: AgentRunConfig
): Promise<string> {
  // LLM configuration — in Labs 1–2 this hits the provider directly;
  // in Lab 3 change llmProxy to $PROXY/llm to route through Kong AI Gateway.
  const llm = llmOpenAI({
    baseURL: cfg.llmProxy ?? "https://api.openai.com",
    apiKey: cfg.openaiApiKey ?? "",
    model: cfg.llmModel ?? "gpt-4o-mini",
  });

  // Three MCP servers — only use them if proxy URL is provided
  // In Lab 2+ an agentApiKey is added as a Bearer token so Kong's
  // Key Auth plugin can authenticate the agent.
  const tools = [];
  if (cfg.proxy) {
    const mcpOptions = cfg.agentApiKey
      ? { auth: { type: "bearer" as const, token: cfg.agentApiKey } }
      : {};

    tools.push(
      // mcp(`${cfg.proxy}/mcp/expense`, mcpOptions),
      // mcp(`${cfg.proxy}/mcp/hr`,      mcpOptions),
      mcp(`${cfg.proxy}/mcp/policy`,  mcpOptions),
    );
  }

  const expenseApprover = agent({
    llm,
    name: "expenser",
    description: "Expense Approval Agent",
    instructions
  });

  let result;
    result = await expenseApprover
    .then({ 
      prompt: "Retrieve the policy and summarize it", 
      // Use MCP tools if proxy is available
        mcps: tools 
      })
      .then({ 
        prompt: `Process the following expense: ${expenseInput}. Return the decision.`
      })
      .run();
  console.log(result)

  // The agent runs multiple steps (LLM → tool calls → LLM → …). The final
  // answer is in the last step that carries a non-empty llmOutput.
  const finalOutput = [...result]
    .reverse()
    .find((s) => s.llmOutput?.trim())
    ?.llmOutput ?? "";

  console.log(`[agent] steps: ${result.length}, output length: ${finalOutput.length}`);

  return finalOutput;
}
