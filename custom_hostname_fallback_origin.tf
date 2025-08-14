locals {
  custom_hostname_fallback_origin = module.this.enabled && var.custom_hostname_fallback_origin != null ? {
    for sett in flatten(var.custom_hostname_fallback_origin) :
    local.zone_id => sett
  } : {}
}

resource "cloudflare_custom_hostname_fallback_origin" "this" {
  for_each = local.custom_hostname_fallback_origin

  zone_id = each.key
  origin  = lookup(each.value, "origin", null)
}
