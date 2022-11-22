locals {
  service_account_name           = "application-sa"
  namespace_name_service_account = "default"
}


resource "azuread_application" "app" {
  display_name = "sp-app-k8s-service-account"
}

resource "azuread_service_principal" "app" {
  application_id = azuread_application.app.application_id
}

resource "azuread_service_principal_password" "app" {
  service_principal_id = azuread_service_principal.app.id
}

resource "azuread_application_federated_identity_credential" "app" {
  application_object_id = azuread_application.app.object_id
  display_name          = "fed-identity-app"
  description           = "The federated identity used to federate K8s with Azure AD with the app service running in k8s"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
  subject               = "system:serviceaccount:${local.namespace_name_service_account}:${local.service_account_name}"
}

resource "kubernetes_service_account" "app_service_account" {
  metadata {
    name      = local.service_account_name
    namespace = local.namespace_name_service_account

    labels = {
      "azure.workload.identity/use" = true
    }
    annotations = {
      "azure.workload.identity/client-id"                        = azuread_application.app.application_id
      "azure.workload.identity/service-account-token-expiration" = 86400
    }
  }
}
