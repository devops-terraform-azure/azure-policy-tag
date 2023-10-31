resource "azurerm_policy_definition" "tags" {
  name         = "Deny-RequiredTag-Resource"
  display_name = "Deny a Required Tag on a Resource"
  description  = "Deny all resources for a required tag"
  policy_type  = "Custom"
  mode         = "All"
  policy_rule  = file("${path.module}/PolicyRule.json")
  parameters   = file("${path.module}/Parameters.json")
  metadata     = file("${path.module}/Metadata.json")
}

resource "azurerm_policy_assignment" "requiredTag" {
    for_each = {
      for id in data.azurerm_management_group.parent_group.management_group_ids :
      id => id
    }
  name                 = "Deny-Tag-${var.requiredTag}"
  display_name         = "Tag '${var.requiredTag}'"
  description          = "Required tag '${var.requiredTag}'"
  policy_definition_id = azurerm_policy_definition.requiredTag.id
  scope                = data.azurerm_management_group.parent_group.id
  parameters           = <<PARAMETERS
  {
    "tagValue": {
        "value": "${var.requiredValue}"
    },
    "tagName": {
        "value": "${var.requiredTag}"
    }
}
PARAMETERS
}


variable "requiredTag" {
  default = "environment"
}

variable "requiredValue" {
  default = "production"
}


data "azurerm_management_group" "parent_group" {
  display_name = ""
}
