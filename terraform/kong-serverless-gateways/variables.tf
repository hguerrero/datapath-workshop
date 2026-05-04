variable "system_account_id" {
  description = "ID of the Konnect system account used for the workshop access token"
  type        = string
}

variable "student_count" {
  description = "Number of student environments to provision"
  type        = number
  default     = 20
}

variable "student_start_number" {
  description = "First student number (zero-padded). Change to resume a partially provisioned cohort."
  type        = number
  default     = 1
}

variable "student_name_prefix" {
  description = "Prefix for all per-student Konnect resources (e.g. 'student-' → 'student-01-cp')"
  type        = string
  default     = "student-"
}

variable "control_plane_description" {
  description = "Description applied to each student control plane"
  type        = string
  default     = "Kong Data Path Workshop — environment for"
}

variable "control_plane_labels" {
  description = "Labels to attach to every student control plane (useful for filtering in the Konnect UI)"
  type        = map(string)
  default = {
    workshop = "data-path"
  }
}

# ── LLM API keys (stored in Konnect Vault — students never see these) ─────────

variable "llm_api_key_openai" {
  description = "OpenAI API key. Stored in each student's Config Store as 'llm-api-key-openai' and referenced in Kong configs as {vault://ai/llm-api-key-openai}."
  type        = string
  sensitive   = true
}

variable "llm_api_key_anthropic" {
  description = "Anthropic API key. Used for LLM failover in Lab 3. Leave empty to skip provisioning the Anthropic secret."
  type        = string
  sensitive   = true
  default     = ""
}

# ── Optional: Kafka (Lab 4) ───────────────────────────────────────────────────

variable "kafka_bootstrap_servers" {
  description = "Kafka bootstrap server address for Lab 4 (e.g. 'b-1.cluster.kafka.us-east-1.amazonaws.com:9092'). Leave empty if not running Lab 4."
  type        = string
  default     = ""
}
