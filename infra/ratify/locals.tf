locals {
  policy_definition = jsondecode(file("${path.module}/ratify-policy.json"))
}