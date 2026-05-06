variable "workshop_system_account_name" {
  description = "Name for the workshop system account"
  type        = string
  default     = "Data Path Workshop System Account"
}

variable "workshop_system_account_description" {
  description = "Description for the workshop system account"
  type        = string
  default     = "System account for Kong Data Path Workshop automation"
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

# ── SSO/OIDC Configuration ────────────────────────────────────────────────────

variable "enable_sso_config" {
  description = "Whether to create and configure SSO/OIDC identity provider. Set to false if you already have an identity provider configured."
  type        = bool
  default     = true
}

variable "workshop_sso_oidc_org_login_path" {
  description = "OIDC login path for the organization SSO (mandatory when enable_sso_config is true)"
  type        = string
  default     = ""
}

variable "workshop_sso_oidc_issuer" {
  description = "OIDC issuer URL for SSO configuration"
  type        = string
  default     = "https://workshop-idp.com"
}

variable "workshop_sso_oidc_client_id" {
  description = "OIDC client ID for SSO configuration"
  type        = string
  default     = "workshop-client-12345"
}

variable "workshop_sso_oidc_client_secret" {
  description = "OIDC client secret for SSO configuration"
  type        = string
  sensitive   = true
  default     = "L2bQ8nZ5yX1wJ"
}
