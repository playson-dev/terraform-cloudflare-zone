locals {
  rulesets = { for rs in var.rulesets : rs.name => rs }
}

resource "cloudflare_ruleset" "default" {
  depends_on = [
    cloudflare_list.this
  ]
  for_each = local.rulesets

  zone_id     = local.zone_id
  name        = each.value.name
  description = lookup(each.value, "description", null)
  kind        = lookup(each.value, "kind", "zone")
  phase       = lookup(each.value, "phase", "http_request_firewall_custom")

  dynamic "rules" {
    for_each = lookup(each.value, "rules", [])
    content {
      ref         = lookup(rules.value, "ref", null)
      expression  = rules.value.expression
      description = lookup(rules.value, "description", null)
      action      = rules.value.action
      enabled     = lookup(rules.value, "enabled", true)

      dynamic "action_parameters" {
        for_each = rules.value.action_parameters != null ? [rules.value.action_parameters] : []
        content {
          # Добавь только те параметры, которые реально используешь!
          id                         = lookup(action_parameters.value, "id", null)
          rulesets                   = lookup(action_parameters.value, "rulesets", null)
          rules                      = lookup(action_parameters.value, "rules", null)
          response                   = lookup(action_parameters.value, "response", null)
          matched_data               = lookup(action_parameters.value, "matched_data", null)
          overrides                  = lookup(action_parameters.value, "overrides", null)
          cache                      = lookup(action_parameters.value, "cache", null)
          security_level             = lookup(action_parameters.value, "security_level", null)
          status_code                = lookup(action_parameters.value, "status_code", null)
          content                    = lookup(action_parameters.value, "content", null)
          content_type               = lookup(action_parameters.value, "content_type", null)
          preserve_query_string      = lookup(action_parameters.value, "preserve_query_string", null)
          target_url                 = lookup(action_parameters.value, "target_url", null)
        }
      }

      dynamic "ratelimit" {
        for_each = lookup(rules.value, "ratelimit", []) != null ? [rules.value.ratelimit] : []
        content {
          characteristics             = ratelimit.value.characteristics
          counting_expression         = lookup(ratelimit.value, "counting_expression", null)
          mitigation_timeout          = ratelimit.value.mitigation_timeout
          period                      = ratelimit.value.period
          requests_per_period         = ratelimit.value.requests_per_period
          requests_to_origin          = lookup(ratelimit.value, "requests_to_origin", null)
          score_per_period            = lookup(ratelimit.value, "score_per_period", null)
          score_response_header_name  = lookup(ratelimit.value, "score_response_header_name", null)
        }
      }

      dynamic "logging" {
        for_each = lookup(rules.value, "logging", []) != null ? [rules.value.logging] : []
        content {
          enabled = lookup(logging.value, "enabled", true)
        }
      }

      dynamic "exposed_credential_check" {
        for_each = lookup(rules.value, "exposed_credential_check", []) != null ? [rules.value.exposed_credential_check] : []
        content {
          password_expression = lookup(exposed_credential_check.value, "password_expression", null)
          username_expression = lookup(exposed_credential_check.value, "username_expression", null)
        }
      }
    }
  }
}
