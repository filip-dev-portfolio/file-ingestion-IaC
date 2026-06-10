data "azurerm_subnet" "subnet" {
    for_each = local.private_endpoints

    name                 = each.value.subnet_name
    virtual_network_name = each.value.vnet_name
    resource_group_name  = each.value.resource_group_name
}

data "azurerm_private_dns_zone" "pdz" {
    for_each = local.private_dns_zone

    name                = each.value.private_dns_zone_name
    resource_group_name = each.value.private_dns_zone_rg
}