data "azurerm_user_assigned_identity" "uai" {
    for_each = {
        for sta_k, sta_v in try(local.storage_accounts, []):
        sta_k => sta_v
        if sta_v.user_assigned_identity != null
    }
    name = each.value.user_assigned_identity
    resource_group_name = each.value.resource_group_name
}