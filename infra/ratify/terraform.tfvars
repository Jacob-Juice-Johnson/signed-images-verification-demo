# Terraform variables file
# Update with your actual values

# Required variables
resource_group_name      = "ratifyrgdemo009"
aks_cluster_name        = "ratifyaksdemo009"
identity_name           = "ratifymidemo009"
key_vault_name          = "ratifykvdemo009"
certificate_name        = "ratify"
certificate_subject_dn  = "C=US, ST=IL, L=Chicago, O=demo.io, OU=Demo, CN=Demo"

# Optional variables (with defaults shown, uncomment to override)
# policy_definition_name = "ratify-default-custom-policy"
# policy_effect         = "Deny"
# excluded_namespaces   = ["kube-system", "gatekeeper-system"]
# namespaces           = []
# label_selector       = {}
# ratify_namespace     = "gatekeeper-system"
