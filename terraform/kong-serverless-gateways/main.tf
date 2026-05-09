locals {
  # Zero-padded IDs: ["01", "02", ..., "20"] (or whatever range is configured)
  student_ids = [
    for i in range(var.student_start_number, var.student_count + var.student_start_number) :
    format("%02d", i)
  ]

  demo_gateway_host = "${split(".", split(":", split("/", trimprefix(trimprefix(data.konnect_gateway_control_plane.demo_cp.config.control_plane_endpoint, "https://"), "http://"))[0])[0])[0]}.us.serverless.gateways.konggateway.com"
}

# ── Workshop System Account ───────────────────────────────────────────────────

resource "konnect_system_account" "workshop_system_account" {
  name         = var.workshop_system_account_name
  description  = var.workshop_system_account_description
  konnect_managed = false
}

# Assign system account to control plane admin team
resource "konnect_system_account_team" "workshop_system_account_team" {
  account_id = konnect_system_account.workshop_system_account.id
  team_id    = data.konnect_team.control_plane_admin.id
}

# ── Per-student Serverless Control Planes ────────────────────────────────────

resource "konnect_gateway_control_plane" "serverless_cp" {
  for_each = toset(local.student_ids)

  name         = "${var.student_name_prefix}${each.key}-cp"
  description  = "${var.control_plane_description} ${var.student_name_prefix}${each.key}"
  cluster_type = "CLUSTER_TYPE_SERVERLESS_V1"
  auth_type    = "pinned_client_certs"
  cloud_gateway = true
  labels       = var.control_plane_labels
}

resource "konnect_cloud_gateway_configuration" "serverless_gw" {
  for_each = toset(local.student_ids)

  control_plane_geo = var.konnect_region
  control_plane_id  = konnect_gateway_control_plane.serverless_cp[each.key].id

  dataplane_groups = [
    {
      provider = "aws"
      region   = var.konnect_region
    }
  ]

  kind = "serverless.v1"
}

# Identity Auth Server per student
resource "konnect_identity_auth_server" "student_auth_server" {
  for_each = toset(local.student_ids)

  name        = "${var.student_name_prefix}${each.key}-auth-server"
  description = "Identity auth server for ${var.student_name_prefix}${each.key}"
  audience    = "https://${var.student_name_prefix}${each.key}.example.com"
}

# Identity Auth Server Client (Application) per student
resource "konnect_identity_auth_server_client" "student_application" {
  for_each = toset(local.student_ids)

  name           = "${var.student_name_prefix}${each.key}-application"
  auth_server_id = konnect_identity_auth_server.student_auth_server[each.key].id
  grant_types    = ["client_credentials"]
  response_types = ["token"]
  redirect_uris  = ["https://httpbin.konghq.com", "https://app.insomnia.rest/oauth/redirect"]
  client_secret  = "supersecret"
  id             = "${var.student_name_prefix}${each.key}"
}



# ── AI Gateway Analytics Dashboard ─────────────────────────────────────────

resource "konnect_dashboard" "ai_gateway_dashboard" {
  provider = konnect-beta
  name     = "AI Gateway Analytics Dashboard"
  
  definition = {
    tiles = [
      {
        chart = {
          type = "chart"
          layout = {
            position = {
              col = 0
              row = 0
            }
            size = {
              cols = 2
              rows = 2
            }
          }
          definition = {
            chart = {
              horizontal_bar = {
                type        = "horizontal_bar"
                stacked     = true
                chart_title = "GenAI model usage count"
              }
            }
            query = {
              llm_usage = {
                datasource = "llm_usage"
                metrics    = ["ai_request_count"]
                dimensions = ["ai_request_model"]
                filters = [
                  {
                    field    = "ai_request_model"
                    operator = "not_empty"
                  },
                  {
                    field    = "ai_request_model"
                    operator = "not_in"
                    value    = jsonencode(["UNSPECIFIED"])
                  }
                ]
              }
            }
          }
        }
      },
      {
        chart = {
          type = "chart"
          layout = {
            position = {
              col = 2
              row = 0
            }
            size = {
              cols = 2
              rows = 2
            }
          }
          definition = {
            chart = {
              horizontal_bar = {
                type        = "vertical_bar"
                stacked     = true
                chart_title = "GenAI provider usage count"
              }
            }
            query = {
              llm_usage = {
                datasource = "llm_usage"
                metrics    = ["ai_request_count"]
                dimensions = ["ai_provider"]
                filters = [
                  {
                    field    = "ai_provider"
                    operator = "not_empty"
                  },
                  {
                    field    = "ai_provider"
                    operator = "not_in"
                    value    = jsonencode(["UNSPECIFIED"])
                  }
                ]
              }
            }
          }
        }
      },
      {
        chart = {
          type = "chart"
          layout = {
            position = {
              col = 4
              row = 0
            }
            size = {
              cols = 2
              rows = 2
            }
          }
          definition = {
            chart = {
              donut = {
                type        = "donut"
                chart_title = "AI status codes"
              }
            }
            query = {
              llm_usage = {
                datasource = "llm_usage"
                metrics    = ["ai_request_count"]
                dimensions = ["status_code_grouped"]
                filters = [
                  {
                    field    = "gateway_service"
                    operator = "not_empty"
                  },
                  {
                    field    = "ai_provider"
                    operator = "not_empty"
                  },
                  {
                    field    = "ai_provider"
                    operator = "not_in"
                    value    = jsonencode(["UNSPECIFIED"])
                  }
                ]
              }
            }
          }
        }
      },
      {
        chart = {
          type = "chart"
          layout = {
            position = {
              col = 0
              row = 2
            }
            size = {
              cols = 3
              rows = 2
            }
          }
          definition = {
            chart = {
              horizontal_bar = {
                type        = "vertical_bar"
                stacked     = true
                chart_title = "AI security report"
              }
            }
            query = {
              llm_usage = {
                datasource = "llm_usage"
                metrics    = ["ai_request_count"]
                dimensions = ["route", "status_code"]
                filters = [
                  {
                    field    = "status_code_grouped"
                    operator = "in"
                    value    = jsonencode(["4XX"])
                  },
                  {
                    field    = "ai_provider"
                    operator = "not_empty"
                  },
                  {
                    field    = "ai_provider"
                    operator = "not_in"
                    value    = jsonencode(["UNSPECIFIED"])
                  }
                ]
              }
            }
          }
        }
      },
      {
        chart = {
          type = "chart"
          layout = {
            position = {
              col = 3
              row = 2
            }
            size = {
              cols = 3
              rows = 2
            }
          }
          definition = {
            chart = {
              timeseries_line = {
                type        = "timeseries_line"
                stacked     = false
                chart_title = "Token usage by provider"
              }
            }
            query = {
              llm_usage = {
                datasource = "llm_usage"
                metrics    = ["total_tokens"]
                dimensions = ["ai_provider", "time"]
                filters = [
                  {
                    field    = "ai_provider"
                    operator = "not_empty"
                  },
                  {
                    field    = "ai_provider"
                    operator = "not_in"
                    value    = jsonencode(["UNSPECIFIED"])
                  }
                ]
              }
            }
          }
        }
      },
      {
        chart = {
          type = "chart"
          layout = {
            position = {
              col = 0
              row = 4
            }
            size = {
              cols = 3
              rows = 2
            }
          }
          definition = {
            chart = {
              horizontal_bar = {
                type        = "horizontal_bar"
                stacked     = true
                chart_title = "Consumer token usage"
              }
            }
            query = {
              llm_usage = {
                datasource = "llm_usage"
                metrics    = ["total_tokens"]
                dimensions = ["consumer", "ai_provider"]
                filters = [
                  {
                    field    = "consumer"
                    operator = "not_empty"
                  },
                  {
                    field    = "ai_provider"
                    operator = "not_empty"
                  },
                  {
                    field    = "ai_provider"
                    operator = "not_in"
                    value    = jsonencode(["UNSPECIFIED"])
                  }
                ]
              }
            }
          }
        }
      },
      {
        chart = {
          type = "chart"
          layout = {
            position = {
              col = 3
              row = 4
            }
            size = {
              cols = 3
              rows = 2
            }
          }
          definition = {
            chart = {
              horizontal_bar = {
                type        = "horizontal_bar"
                stacked     = true
                chart_title = "Cost per consumer ($)"
              }
            }
            query = {
              llm_usage = {
                datasource = "llm_usage"
                metrics    = ["cost"]
                dimensions = ["consumer", "ai_provider"]
                filters = [
                  {
                    field    = "consumer"
                    operator = "not_empty"
                  },
                  {
                    field    = "ai_provider"
                    operator = "not_empty"
                  },
                  {
                    field    = "ai_provider"
                    operator = "not_in"
                    value    = jsonencode(["UNSPECIFIED"])
                  }
                ]
              }
            }
          }
        }
      },
      {
        chart = {
          type = "chart"
          layout = {
            position = {
              col = 0
              row = 6
            }
            size = {
              cols = 3
              rows = 1
            }
          }
          definition = {
            chart = {
              single_value = {
                type        = "single_value"
                decimal_points = 2
                chart_title = "Total cost ($)"
              }
            }
            query = {
              llm_usage = {
                datasource = "llm_usage"
                metrics    = ["cost"]
                dimensions = []
                filters = [
                  {
                    field    = "ai_provider"
                    operator = "not_empty"
                  },
                  {
                    field    = "ai_provider"
                    operator = "not_in"
                    value    = jsonencode(["UNSPECIFIED"])
                  }
                ]
              }
            }
          }
        }
      },
      {
        chart = {
          type = "chart"
          layout = {
            position = {
              col = 3
              row = 6
            }
            size = {
              cols = 3
              rows = 1
            }
          }
          definition = {
            chart = {
              single_value = {
                type        = "single_value"
                decimal_points = 2
                chart_title = "Total AI gateway requests"
              }
            }
            query = {
              llm_usage = {
                datasource = "llm_usage"
                metrics    = ["ai_request_count"]
                dimensions = []
                filters = [
                  {
                    field    = "ai_provider"
                    operator = "not_empty"
                  },
                  {
                    field    = "ai_provider"
                    operator = "not_in"
                    value    = jsonencode(["UNSPECIFIED"])
                  }
                ]
              }
            }
          }
        }
      }
    ]
  }
  
  labels = {
    environment = "workshop"
    purpose     = "ai-analytics"
  }
}

# ── Config Store + Vault per student (LLM API keys) ──────────────────────────

resource "konnect_gateway_config_store" "student_config_store" {
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  name             = "${var.student_name_prefix}${each.key}-config-store"
}

resource "konnect_gateway_vault" "student_vault" {
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  name             = "konnect"
  prefix           = "ai"
  description      = "Konnect config store vault for ${var.student_name_prefix}${each.key}"
  config = jsonencode({
    config_store_id = konnect_gateway_config_store.student_config_store[each.key].id
  })
}

# ── LLM API key secrets (stored in each student's Config Store) ───────────────
# These are referenced in decK configs as {vault://ai/llm-api-key-openai} etc.
# Students never see the raw keys — Kong resolves them at request time.

resource "konnect_gateway_config_store_secret" "llm_openai" {
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  config_store_id  = konnect_gateway_config_store.student_config_store[each.key].id
  key              = "llm-api-key-openai"
  value            = "Bearer ${var.llm_api_key_openai}"
}

resource "konnect_gateway_config_store_secret" "llm_anthropic" {
  # Only provision if an Anthropic key has been provided (Lab 3 failover)
  # for_each = var.llm_api_key_anthropic != "" ? toset(local.student_ids) : toset([])
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  config_store_id  = konnect_gateway_config_store.student_config_store[each.key].id
  key              = "llm-api-key-anthropic"
  value            = "Bearer ${var.llm_api_key_anthropic}"
}

# ── expense-agent consumer + API key (pre-seeded for Lab 2+) ─────────────────

resource "konnect_gateway_consumer" "expense_agent" {
  for_each = toset(local.student_ids)

  username         = "expense-agent"
  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
}

# resource "konnect_gateway_consumer_key_auth" "expense_agent_key" {
#   for_each = toset(local.student_ids)

#   consumer_username = konnect_gateway_consumer.expense_agent[each.key].username
#   consumer_id       = konnect_gateway_consumer.expense_agent[each.key].id
#   control_plane_id  = konnect_gateway_control_plane.serverless_cp[each.key].id
#   # key is auto-generated by Konnect when omitted
# }

# ── Organization SSO Configuration ────────────────────────────────────────────

# Create the OIDC identity provider (only if not already exists)
resource "konnect_identity_provider" "org_sso_config" {
  count = var.enable_sso_config ? 1 : 0

  type       = "oidc"
  login_path = var.workshop_sso_oidc_org_login_path
  enabled    = true

  config = {
    oidc_identity_provider_config = {
      issuer_url    = var.workshop_sso_oidc_issuer
      client_id     = var.workshop_sso_oidc_client_id
      client_secret = var.workshop_sso_oidc_client_secret

      scopes = [
        "openid",
        "email",
        "profile"
      ]

      claim_mappings = {
        email  = "email"
        name   = "name"
        groups = "groups"
      }
    }
  }
}

# Enable Organization SSO (only if creating identity provider)
resource "konnect_authentication_settings" "enable_org_sso_config" {
  count = var.enable_sso_config ? 1 : 0

  basic_auth_enabled      = true
  oidc_auth_enabled       = true
  saml_auth_enabled       = false
  idp_mapping_enabled     = true
  konnect_mapping_enabled = true

  depends_on = [konnect_identity_provider.org_sso_config]
}

# ── Collect default Konnect Teams for SSO Team Mappings ──────────────────────

data "konnect_team" "organization_admin" {
  filter = { name = { eq = "organization-admin" } }
}

data "konnect_team" "control_plane_admin" {
  filter = { name = { eq = "control-plane-admin" } }
}

data "konnect_team" "organization_admin_readonly" {
  filter = { name = { eq = "organization-admin-readonly" } }
}

data "konnect_team" "analytics_admin" {
  filter = { name = { eq = "analytics-admin" } }
}

data "konnect_team" "portal_admin" {
  filter = { name = { eq = "portal-admin" } }
}

# Create the Team Mappings (only if creating identity provider)
resource "null_resource" "org_sso_team_mappings" {
  count = var.enable_sso_config ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      curl --request PATCH \
          --url "${var.konnect_api_url}/v3/identity-provider/team-group-mappings" \
          --header "Authorization: Bearer ${var.konnect_personal_access_token}" \
          --header 'Content-Type: application/json' \
          --data '{
          "data": [
            {
              "team_id": "${data.konnect_team.organization_admin.id}",
              "groups": [
                "Custom User",
                "Custom Admin",
                "Custom Viewer"
              ]
            },
            {
              "team_id": "${data.konnect_team.control_plane_admin.id}",
              "groups": [
                "Control Plane Admin"
              ]
            },
            {
              "team_id": "${data.konnect_team.organization_admin_readonly.id}",
              "groups": [
                "Organization Admin RO"
              ]
            },
            {
              "team_id": "${data.konnect_team.analytics_admin.id}",
              "groups": [
                "Analytics Admin"
              ]
            },
            {
              "team_id": "${data.konnect_team.portal_admin.id}",
              "groups": [
                "Portal Admin",
                "API Product Developer",
                "API Product Admin"
              ]
            }
          ]
        }'
EOT
  }

  depends_on = [
    konnect_identity_provider.org_sso_config,
    konnect_authentication_settings.enable_org_sso_config
  ]
}

# ── Reference Existing Demo Control Plane for Lab 1 Agent Loop ──────────────

data "konnect_gateway_control_plane" "demo_cp" {
}

# ── Lab 1: Policy API Service ────────────────────────────────────────────────

resource "konnect_gateway_service" "policy_api_service" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  name             = "policy-api-service"
  protocol         = "http"
  host             = "mock-policy.internal"
  port             = 80
  path             = "/"
}

# Policy MCP Route with AI MCP Proxy Plugin
resource "konnect_gateway_route" "policy_mcp" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  name             = "policy-mcp"
  service = {
    id = konnect_gateway_service.policy_api_service.id
  }
  paths = ["/mcp/policy"]
}

resource "konnect_gateway_plugin_ai_mcp_proxy" "policy_mcp_ai_proxy" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  instance_name    = "policy-mcp-ai-proxy"
  route = {
    id = konnect_gateway_route.policy_mcp.id
  }
  config = {
    mode = "conversion-listener"
    logging = {
      log_audits     = true
      log_payloads   = true
      log_statistics = true
    }
    max_request_body_size = 32768
    tools = [
      {
        name = "getPolicy"
        annotations = {
          title = "Get Company Policy"
        }
        description = "Returns the company-wide policy rules"
        path        = "/policy-api/policy"
        method      = "GET"
      }
    ]
  }
}

# Per-student copies of the Lab 1 MCP proxy stack
resource "konnect_gateway_service" "student_policy_api_service" {
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  name             = "${var.student_name_prefix}${each.key}-policy-api-service"
  protocol         = "https"
  host             = local.demo_gateway_host
  path             = "/mcp/policy"
  port             = 443
}

resource "konnect_gateway_route" "student_policy_mcp" {
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  name             = "${var.student_name_prefix}${each.key}-policy-mcp"
  service = {
    id = konnect_gateway_service.student_policy_api_service[each.key].id
  }
  paths = ["/mcp/policy"]
}

resource "konnect_gateway_plugin_ai_mcp_proxy" "student_policy_mcp_ai_proxy" {
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  instance_name    = "${var.student_name_prefix}${each.key}-policy-mcp-ai-proxy"
  route = {
    id = konnect_gateway_route.student_policy_mcp[each.key].id
  }
  config = {
    mode = "passthrough-listener"
    logging = {
      log_audits     = true
      log_payloads   = true
      log_statistics = true
    }
    max_request_body_size = 32768
  }
}

# Policy API Route with Mocking Plugin
resource "konnect_gateway_route" "policy_api_route" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  name             = "policy-api-route"
  service = {
    id = konnect_gateway_service.policy_api_service.id
  }
  paths      = ["/policy-api"]
  strip_path = true
}

resource "konnect_gateway_plugin_mocking" "policy_api_mocking" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  instance_name    = "policy-api-mocking"
  route = {
    id = konnect_gateway_route.policy_api_route.id
  }
  config = {
    include_base_path  = true
    custom_base_path   = "/policy-api"
    api_specification = <<-EOT
openapi: "3.0.3"
info:
  title: Policy Service
  description: >
    Returns company expense policy rules and evaluates whether a specific
    expense complies with them. The agent calls this service to get the
    reasoning context it needs before calling the expense service to act.
    Kong's Mocking plugin serves these example responses directly —
    no upstream service is required.
  version: "1.0.0"

paths:
  /policy:
    get:
      operationId: getPolicy
      summary: Retrieve the current expense policy
      description: >
        Returns the company-wide policy rules: approval thresholds,
        categories that require receipts, and categories that always
        require escalation regardless of amount.
      responses:
        "200":
          description: Current policy
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Policy"
              example:
                autoApproveLimit: 200
                escalateThreshold: 1000
                receiptRequiredAbove: 75
                alwaysEscalateCategories:
                  - travel
                  - conference
                  - equipment
                alwaysRejectCategories:
                  - personal
                  - alcohol
                  - gambling
                version: "2025-Q2"

components:
  schemas:
    Policy:
      type: object
      properties:
        autoApproveLimit:
          type: number
          description: Expenses at or below this amount are auto-approvable (USD)
          example: 200
        escalateThreshold:
          type: number
          description: Expenses at or above this amount always require human sign-off (USD)
          example: 1000
        receiptRequiredAbove:
          type: number
          description: Receipt must be attached for expenses above this amount (USD)
          example: 75
        alwaysEscalateCategories:
          type: array
          items:
            type: string
          description: Categories that always require escalation regardless of amount
          example: [travel, conference, equipment]
        alwaysRejectCategories:
          type: array
          items:
            type: string
          description: Categories that are never reimbursable
          example: [personal, alcohol, gambling]
        version:
          type: string
          example: "2025-Q2"
EOT
  }
}

# ── Lab 1: HR Service ─────────────────────────────────────────────────────────

resource "konnect_gateway_service" "hr_api_service" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  name             = "hr-api-service"
  protocol         = "http"
  host             = "mock-hr.internal"
  port             = 80
  path             = "/"
}

# HR MCP Route with AI MCP Proxy Plugin
resource "konnect_gateway_route" "hr_mcp" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  name             = "hr-mcp"
  service = {
    id = konnect_gateway_service.hr_api_service.id
  }
  paths = ["/mcp/hr"]
}

resource "konnect_gateway_plugin_ai_mcp_proxy" "hr_mcp_ai_proxy" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  instance_name    = "hr-mcp-ai-proxy"
  route = {
    id = konnect_gateway_route.hr_mcp.id
  }
  config = {
    mode = "conversion-listener"
    logging = {
      log_audits     = true
      log_payloads   = true
      log_statistics = true
    }
    max_request_body_size = 32768
    tools = [
      {
        name = "getEmployee"
        annotations = {
          title = "Get Employee Details"
        }
        description = "Look up an employee by ID to get their spending limits and department info"
        path        = "/hr-api/employees/{id}"
        method      = "GET"
        parameters = [
          {
            name     = "id"
            in       = "path"
            required = true
            schema = {
              type = "string"
            }
            description = "Employee ID (e.g., emp-001, emp-002, emp-003)"
          }
        ]
      },
      {
        name = "getDepartment"
        annotations = {
          title = "Get Department Details"
        }
        description = "Look up a department by ID to get spending limits and manager contact"
        path        = "/hr-api/departments/{id}"
        method      = "GET"
        parameters = [
          {
            name     = "id"
            in       = "path"
            required = true
            schema = {
              type = "string"
            }
            description = "Department ID (e.g., dept-eng, dept-finance)"
          }
        ]
      }
    ]
  }
}

resource "konnect_gateway_service" "student_hr_api_service" {
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  name             = "${var.student_name_prefix}${each.key}-hr-api-service"
  protocol         = "https"
  host             = local.demo_gateway_host
  path             = "/mcp/hr"
  port             = 443
}

resource "konnect_gateway_route" "student_hr_mcp" {
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  name             = "${var.student_name_prefix}${each.key}-hr-mcp"
  service = {
    id = konnect_gateway_service.student_hr_api_service[each.key].id
  }
  paths = ["/mcp/hr"]
}

resource "konnect_gateway_plugin_ai_mcp_proxy" "student_hr_mcp_ai_proxy" {
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  instance_name    = "${var.student_name_prefix}${each.key}-hr-mcp-ai-proxy"
  route = {
    id = konnect_gateway_route.student_hr_mcp[each.key].id
  }
  config = {
    mode = "passthrough-listener"
    logging = {
      log_audits     = true
      log_payloads   = true
      log_statistics = true
    }
    max_request_body_size = 32768
  }
}

# HR API Route with Mocking Plugin
resource "konnect_gateway_route" "hr_api_route" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  name             = "hr-api-route"
  service = {
    id = konnect_gateway_service.hr_api_service.id
  }
  paths = [
    "~/hr-api/employees/(?<employee_id>[^/]+)/?$",
    "~/hr-api/departments/(?<department_id>[^/]+)/?$"
  ]
  strip_path = true
}

resource "konnect_gateway_plugin_request_transformer_advanced" "hr_api_transformer" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  instance_name    = "hr-api-transformer"
  route = {
    id = konnect_gateway_route.hr_api_route.id
  }
  config = {
    add = {
      headers = [
        "X-Kong-Mocking-Example-Id:$(uri_captures['employee_id'] or uri_captures['department_id'])"
      ]
    }
  }
}

resource "konnect_gateway_plugin_mocking" "hr_api_mocking" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  instance_name    = "hr-api-mocking"
  route = {
    id = konnect_gateway_route.hr_api_route.id
  }
  config = {
    include_base_path  = true
    custom_base_path   = "/hr-api"
    api_specification = <<-EOT
openapi: "3.0.3"
info:
  title: HR Service
  description: >
    Provides employee and department context that the agent uses when
    evaluating whether an expense is within the submitter's spending limits.
    Kong's Mocking plugin serves these example responses directly —
    no upstream service is required.
  version: "1.0.0"

paths:
  /employees/{id}:
    get:
      operationId: getEmployee
      summary: Look up an employee by ID
      description: >
        Returns the employee's name, department, title, and individual
        spending limit. The agent uses spendingLimit to decide whether
        to approve or escalate.
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
          examples:
            emp-001:
              value: emp-001
              summary: Alice — junior engineer, $200 limit
            emp-002:
              value: emp-002
              summary: Bob — senior engineer, $500 limit
            emp-003:
              value: emp-003
              summary: Clara — engineering manager, $2000 limit
      responses:
        "200":
          description: Employee record
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Employee"
              examples:
                emp-001:
                  summary: Alice Nguyen — Software Engineer, $200 limit
                  value:
                    id: emp-001
                    name: Alice Nguyen
                    title: Software Engineer
                    departmentId: dept-eng
                    spendingLimit: 200
                    managerId: emp-010
                emp-002:
                  summary: Bob Okafor — Senior Engineer, $500 limit
                  value:
                    id: emp-002
                    name: Bob Okafor
                    title: Senior Engineer
                    departmentId: dept-eng
                    spendingLimit: 500
                    managerId: emp-010
                emp-003:
                  summary: Clara Reyes — Engineering Manager, $2000 limit
                  value:
                    id: emp-003
                    name: Clara Reyes
                    title: Engineering Manager
                    departmentId: dept-eng
                    spendingLimit: 2000
                    managerId: emp-020
        "404":
          description: Employee not found
          content:
            application/json:
              example:
                message: Employee not found

  /departments/{id}:
    get:
      operationId: getDepartment
      summary: Look up a department by ID
      description: >
        Returns department-level spending limits and the manager's
        contact, used for escalation routing.
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
          examples:
            dept-eng:
              value: dept-eng
              summary: Engineering department
      responses:
        "200":
          description: Department record
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Department"
              examples:
                dept-eng:
                  summary: Engineering
                  value:
                    id: dept-eng
                    name: Engineering
                    managerId: emp-003
                    managerEmail: clara.reyes@example.com
                    departmentSpendingLimit: 5000
                dept-finance:
                  summary: Finance
                  value:
                    id: dept-finance
                    name: Finance
                    managerId: emp-020
                    managerEmail: finance-mgr@example.com
                    departmentSpendingLimit: 10000
        "404":
          description: Department not found
          content:
            application/json:
              example:
                message: Department not found

components:
  schemas:
    Employee:
      type: object
      properties:
        id:
          type: string
          example: emp-001
        name:
          type: string
          example: Alice Nguyen
        title:
          type: string
          example: Software Engineer
        departmentId:
          type: string
          example: dept-eng
        spendingLimit:
          type: number
          description: Maximum expense amount this employee can self-approve (USD)
          example: 200
        managerId:
          type: string
          example: emp-010

    Department:
      type: object
      properties:
        id:
          type: string
          example: dept-eng
        name:
          type: string
          example: Engineering
        managerId:
          type: string
          example: emp-003
        managerEmail:
          type: string
          example: clara.reyes@example.com
        departmentSpendingLimit:
          type: number
          description: Maximum single expense amount for the department (USD)
          example: 5000
EOT
  }
}

# ── Lab 1: Expense Service ────────────────────────────────────────────────────

resource "konnect_gateway_service" "expense_api_service" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  name             = "expense-api-service"
  protocol         = "http"
  host             = "mock-expense.internal"
  port             = 80
  path             = "/"
}

# Expense MCP Route with AI MCP Proxy Plugin
resource "konnect_gateway_route" "expense_mcp" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  name             = "expense-mcp"
  service = {
    id = konnect_gateway_service.expense_api_service.id
  }
  paths = ["/mcp/expense"]
}

resource "konnect_gateway_plugin_ai_mcp_proxy" "expense_mcp_ai_proxy" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  instance_name    = "expense-mcp-ai-proxy"
  route = {
    id = konnect_gateway_route.expense_mcp.id
  }
  config = {
    mode = "conversion-listener"
    logging = {
      log_audits     = true
      log_payloads   = true
      log_statistics = true
    }
    max_request_body_size = 32768
    tools = [
      {
        name = "getExpense"
        annotations = {
          title = "Get Expense Record"
        }
        description = "Retrieve a single expense record by ID"
        path        = "/expense-api/expenses/{id}"
        method      = "GET"
        parameters = [
          {
            name     = "id"
            in       = "path"
            required = true
            schema = {
              type = "string"
            }
            description = "Expense ID"
          }
        ]
      },
      {
        name = "approveExpense"
        annotations = {
          title = "Approve Expense"
        }
        description = "Approve an expense within policy limits"
        path        = "/expense-api/approve"
        method      = "POST"
        request_body = jsonencode({
          required = true
          content = {
            "application/json" = {
              schema = {
                type = "object"
                required = ["amount", "description", "employeeId"]
                properties = {
                  amount = {
                    type = "number"
                    description = "Expense amount in USD"
                  }
                  description = {
                    type = "string"
                    description = "Human-readable description of the expense"
                  }
                  employeeId = {
                    type = "string"
                    description = "ID of the employee submitting the expense"
                  }
                  category = {
                    type = "string"
                    description = "Expense category (travel, meals, equipment, etc.)"
                  }
                  reason = {
                    type = "string"
                    description = "Agent's reasoning for this decision"
                  }
                }
              }
            }
          }
        })
      },
      {
        name = "rejectExpense"
        annotations = {
          title = "Reject Expense"
        }
        description = "Reject an expense that violates policy"
        path        = "/expense-api/reject"
        method      = "POST"
        request_body = jsonencode({
          required = true
          content = {
            "application/json" = {
              schema = {
                type = "object"
                required = ["amount", "description", "employeeId"]
                properties = {
                  amount = {
                    type = "number"
                    description = "Expense amount in USD"
                  }
                  description = {
                    type = "string"
                    description = "Human-readable description of the expense"
                  }
                  employeeId = {
                    type = "string"
                    description = "ID of the employee submitting the expense"
                  }
                  category = {
                    type = "string"
                    description = "Expense category (travel, meals, equipment, etc.)"
                  }
                  reason = {
                    type = "string"
                    description = "Agent's reasoning for this decision"
                  }
                }
              }
            }
          }
        })
      },
      {
        name = "escalateExpense"
        annotations = {
          title = "Escalate Expense"
        }
        description = "Escalate an expense for human review when it exceeds approval thresholds"
        path        = "/expense-api/escalate"
        method      = "POST"
        request_body = jsonencode({
          required = true
          content = {
            "application/json" = {
              schema = {
                type = "object"
                required = ["amount", "description", "employeeId"]
                properties = {
                  amount = {
                    type = "number"
                    description = "Expense amount in USD"
                  }
                  description = {
                    type = "string"
                    description = "Human-readable description of the expense"
                  }
                  employeeId = {
                    type = "string"
                    description = "ID of the employee submitting the expense"
                  }
                  category = {
                    type = "string"
                    description = "Expense category (travel, meals, equipment, etc.)"
                  }
                  reason = {
                    type = "string"
                    description = "Agent's reasoning for this decision"
                  }
                }
              }
            }
          }
        })
      }
    ]
  }
}

resource "konnect_gateway_service" "student_expense_api_service" {
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  name             = "${var.student_name_prefix}${each.key}-expense-api-service"
  protocol         = "https"
  host             = local.demo_gateway_host
  path             = "/mcp/expense"
  port             = 443
}

resource "konnect_gateway_route" "student_expense_mcp" {
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  name             = "${var.student_name_prefix}${each.key}-expense-mcp"
  service = {
    id = konnect_gateway_service.student_expense_api_service[each.key].id
  }
  paths = ["/mcp/expense"]
}

resource "konnect_gateway_plugin_ai_mcp_proxy" "student_expense_mcp_ai_proxy" {
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  instance_name    = "${var.student_name_prefix}${each.key}-expense-mcp-ai-proxy"
  route = {
    id = konnect_gateway_route.student_expense_mcp[each.key].id
  }
  config = {
    mode = "passthrough-listener"
    logging = {
      log_audits     = true
      log_payloads   = true
      log_statistics = true
    }
    max_request_body_size = 32768
  }
}

# Expense API Route with Mocking Plugin
resource "konnect_gateway_route" "expense_api_route" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  name             = "expense-api-route"
  service = {
    id = konnect_gateway_service.expense_api_service.id
  }
  paths      = ["/expense-api"]
  strip_path = true
}

resource "konnect_gateway_plugin_mocking" "expense_api_mocking" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  instance_name    = "expense-api-mocking"
  route = {
    id = konnect_gateway_route.expense_api_route.id
  }
  config = {
    include_base_path  = true
    custom_base_path   = "/expense-api"
    api_specification = <<-EOT
openapi: "3.0.3"
info:
  title: Expense Service
  description: >
    Records expense decisions produced by the agent.
    Kong's Mocking plugin serves these example responses directly —
    no upstream service is required.
  version: "1.0.0"

paths:
  /health:
    get:
      operationId: healthCheck
      summary: Liveness probe
      responses:
        "200":
          description: Service is up
          content:
            application/json:
              schema:
                type: object
              example:
                status: ok
                service: expense-service

  /expenses/{id}:
    get:
      operationId: getExpense
      summary: Retrieve a single expense record by ID
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        "200":
          description: Expense record
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Expense"
              example:
                id: EXP-A3F7C1B2
                amount: 150
                description: Team lunch
                employeeId: emp-001
                category: meals
                status: approved
                timestamp: "2025-01-15T14:30:00Z"
        "404":
          description: Not found
          content:
            application/json:
              example:
                message: Expense not found

  /approve:
    post:
      operationId: approveExpense
      summary: Approve an expense
      description: >
        Records a positive decision and returns a confirmation ID.
        Call this when the expense is within policy limits and the
        employee is in good standing.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/DecisionRequest"
            example:
              amount: 150
              description: Team lunch
              employeeId: emp-001
              category: meals
              reason: Amount is within the $200 auto-approve limit and the meals category is compliant.
      responses:
        "200":
          description: Expense approved
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/DecisionResponse"
              example:
                id: EXP-A3F7C1B2
                status: approved
                message: "Expense approved. Reference: EXP-A3F7C1B2"
                timestamp: "2025-01-15T14:30:00Z"

  /reject:
    post:
      operationId: rejectExpense
      summary: Reject an expense
      description: >
        Records a rejection and returns the rejection reason.
        Call this when the expense violates policy or the
        employee's spending limit.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/DecisionRequest"
            example:
              amount: 80
              description: Client dinner
              employeeId: emp-002
              category: alcohol
              reason: The 'alcohol' category is prohibited under company policy regardless of amount.
      responses:
        "200":
          description: Expense rejected
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/DecisionResponse"
              example:
                id: EXP-B8D2E4F6
                status: rejected
                message: "Expense rejected. Reference: EXP-B8D2E4F6"
                timestamp: "2025-01-15T14:31:00Z"

  /escalate:
    post:
      operationId: escalateExpense
      summary: Escalate an expense for human review
      description: >
        Flags the expense for manager review and returns a ticket ID.
        Call this when the amount exceeds the autonomous approval threshold
        or when the category requires sign-off.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/DecisionRequest"
            example:
              amount: 2500
              description: Annual developer conference in Austin
              employeeId: emp-002
              category: conference
              reason: Amount exceeds the $1000 escalation threshold and 'conference' is an always-escalate category.
      responses:
        "200":
          description: Expense escalated
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/DecisionResponse"
              example:
                id: EXP-C9F3A1D7
                status: escalated
                message: "Expense escalated for manager review. Ticket: EXP-C9F3A1D7"
                timestamp: "2025-01-15T14:32:00Z"

components:
  schemas:
    DecisionRequest:
      type: object
      required: [amount, description, employeeId]
      properties:
        amount:
          type: number
          description: Expense amount in USD
          example: 150
        description:
          type: string
          description: Human-readable description of the expense
          example: Team lunch
        employeeId:
          type: string
          description: ID of the employee submitting the expense
          example: emp-001
        category:
          type: string
          description: Expense category (travel, meals, equipment, etc.)
          example: meals
        reason:
          type: string
          description: Agent's reasoning for this decision

    DecisionResponse:
      type: object
      properties:
        id:
          type: string
          description: Unique record ID (e.g. EXP-A3F7C1B2)
          example: EXP-A3F7C1B2
        status:
          type: string
          enum: [approved, rejected, escalated]
          example: approved
        message:
          type: string
          example: "Expense approved. Reference: EXP-A3F7C1B2"
        timestamp:
          type: string
          format: date-time
          example: "2025-01-15T14:30:00Z"

    Expense:
      type: object
      properties:
        id:
          type: string
          example: EXP-A3F7C1B2
        amount:
          type: number
          example: 150
        description:
          type: string
          example: Team lunch
        employeeId:
          type: string
          example: emp-001
        category:
          type: string
          example: meals
        status:
          type: string
          enum: [approved, rejected, escalated, pending]
          example: approved
        timestamp:
          type: string
          format: date-time
          example: "2025-01-15T14:30:00Z"
EOT
  }
}

# ── Consumer groups for ACL-based tool scoping (Lab 2) ───────────────────────

resource "konnect_gateway_consumer_group" "expense_agents" {
  for_each = toset(local.student_ids)

  name             = "expense-agents"
  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
}

resource "konnect_gateway_consumer_group" "escalation_approved" {
  for_each = toset(local.student_ids)

  name             = "escalation-approved"
  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
}

resource "konnect_gateway_consumer_group_member" "agent_expense_agents" {
  for_each = toset(local.student_ids)

  consumer_id       = konnect_gateway_consumer.expense_agent[each.key].id
  consumer_group_id = konnect_gateway_consumer_group.expense_agents[each.key].id
  control_plane_id  = konnect_gateway_control_plane.serverless_cp[each.key].id
}

resource "konnect_gateway_consumer_group_member" "agent_escalation_approved" {
  for_each = toset(local.student_ids)

  consumer_id       = konnect_gateway_consumer.expense_agent[each.key].id
  consumer_group_id = konnect_gateway_consumer_group.escalation_approved[each.key].id
  control_plane_id  = konnect_gateway_control_plane.serverless_cp[each.key].id
}

# ── Global CORS plugin (one per control plane) ───────────────────────────────

resource "konnect_gateway_plugin_cors" "global_cors" {
  for_each = toset(local.student_ids)

  control_plane_id = konnect_gateway_control_plane.serverless_cp[each.key].id
  instance_name    = "global-cors"

  config = {
    allow_origin_absent = true
    origins             = ["*"]
    methods             = ["GET", "HEAD", "PUT", "PATCH", "POST", "DELETE", "OPTIONS", "TRACE", "CONNECT"]
    credentials         = true
    max_age             = 3600
    preflight_continue  = false
  }
}

resource "konnect_gateway_plugin_cors" "demo_global_cors" {
  control_plane_id = data.konnect_gateway_control_plane.demo_cp.id
  instance_name    = "demo-global-cors"

  config = {
    allow_origin_absent = true
    origins             = ["*"]
    methods             = ["GET", "HEAD", "PUT", "PATCH", "POST", "DELETE", "OPTIONS", "TRACE", "CONNECT"]
    credentials         = true
    max_age             = 3600
    preflight_continue  = false
  }
}

# ── System account token (shared — used for decK syncs in lab instructions) ──

resource "konnect_system_account_access_token" "token" {
  account_id = konnect_system_account.workshop_system_account.id
  expires_at = timeadd(timestamp(), "8760h") # 1 year — refresh before next cohort
  name       = "${var.student_name_prefix}-workshop-token"
}
