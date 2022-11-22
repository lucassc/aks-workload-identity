resource "helm_release" "prometheus_operator" {
  name       = "prometheus"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kube-prometheus"

  namespace        = "monitoring"
  create_namespace = true
}

data "azurerm_client_config" "current" {}


resource "helm_release" "azure-workload-identity-system" {
  name       = "workload-identity-webhook"
  chart      = "workload-identity-webhook"
  repository = "https://azure.github.io/azure-workload-identity/charts"
  wait       = false

  namespace        = "azure-workload-identity-system"
  create_namespace = true

  set {
    name  = "azureTenantID"
    value = data.azurerm_client_config.current.tenant_id
  }
}

