/**
 * Reads all Kong + LLM configuration from environment variables.
 *
 * Students: copy .env.example → .env and fill in the values provided
 * by your instructor before running the agent.
 */

function required(name: string): string {
  const val = process.env[name];
  if (!val) {
    throw new Error(
      `Missing required environment variable: ${name}\n` +
        `Copy .env.example to .env and fill in the value.`
    );
  }
  return val;
}

function optional(name: string, fallback: string): string {
  return process.env[name] ?? fallback;
}

export const config = {
  // Kong Serverless Gateway proxy base URL
  proxy: required("PROXY"),

  // LLM provider — direct in Labs 1–2, via Kong AI Gateway in Lab 3+
  llmProxy: optional("LLM_PROXY", "https://api.openai.com"),
  openaiApiKey: required("OPENAI_API_KEY"),
  llmModel: optional("LLM_MODEL", "gpt-4o-mini"),

  // Kong consumer API key (empty in Lab 1)
  agentApiKey: optional("AGENT_API_KEY", ""),

  // MCP server URLs — all traffic routes through the Kong proxy
  tools: {
    expenseMcpUrl: optional(
      "EXPENSE_MCP_URL",
      `${process.env.PROXY}/mcp/expense`
    ),
    hrMcpUrl: optional("HR_MCP_URL", `${process.env.PROXY}/mcp/hr`),
    policyMcpUrl: optional(
      "POLICY_MCP_URL",
      `${process.env.PROXY}/mcp/policy`
    ),
  },
} as const;
