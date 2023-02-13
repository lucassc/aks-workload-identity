This repository contains the code to deploy a Azure Kubernetes Service with all dependencies needed to use Azure AD Workload Identity

# Requirements 

 - [Terraform](https://developer.hashicorp.com/terraform)
 - [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
 - [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)


# Step 1 - Create AKS cluster

``` BASH
export KEY_VAULT_NAME=<your-key-vault-name>  ## example: myvaultname
export TF_VAR_key_vault_name=$KEY_VAULT_NAME

terraform init

terraform plan -var-file values.tfvars -out plan.bin

terraform apply plan.bin
```

# Step 2 - Create a secret 

``` BASH
# get your objectid
OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
# Set permissions to your user
az keyvault set-policy --name $KEY_VAULT_NAME --object-id $OBJECT_ID --secret-permissions all

#create a secret
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "my-secret-name" --value "my-value"
```

# Step 3 - Connect to cluster

``` BASH
az account set --subscription <your-subscription-id>

az aks get-credentials --resource-group k8s-rg --name aks-cluster
```

# Step 4 - Create deployment and service

``` BASH
WORKLOADS=$(cat ./workloads.yaml) && \
    echo "${WORKLOADS/VAULT_NAME_TO_REPLACE/$KEY_VAULT_NAME}" | kubectl create -f -
```
The source code for these application is inside the repository, go to [vault.reader](vault.reader/)

# Step 5 - Test 

! Important ! Vault-reader load the secrets when the pod starts. When a change in the vault secret happens, you will need to restart the pod. 

``` BASH
kubectl port-forward deployment/vault-reader 8888:8888
```

Now you need to open another terminal to get the secret value
``` BASH
curl --location --request GET 'http://127.0.0.1:8888/get-secret/my-secret-name'
```

This curl command will return a json object with the key and the secret value created on step 2

Example: 

``` json
{
  "key": "my-secret-name",
  "value": "my-value"
}
```

You also can request the secret value using the application Swagger page: http://127.0.0.1:8888/swagger/index.html

# Step 6 - Check the pod envs
In this step is possible to see the environment variables injected in the POD 
``` BASH
kubectl exec deployment/vault-reader -- printenv | grep AZURE_
```

The response will be like:
``` BASH
AZURE_CLIENT_ID=<service-principal-id>
AZURE_TENANT_ID=<your-tenant-id>
AZURE_FEDERATED_TOKEN_FILE=/var/run/secrets/azure/tokens/azure-identity-token
AZURE_AUTHORITY_HOST=https://login.microsoftonline.com/
```

# After all: DESTROY!!!

To avoid surprises, don't forget to delete the resources.

``` BASH
terraform destroy -auto-approve -var-file values.tfvars
```
