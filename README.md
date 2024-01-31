# terraform-azure

## Terraform commans to remember

```bash
terraform validate  #Validates the code for syntax errors
terraform init  #Initializes the configuration
terrraform plan #Check what changes will be made with your code
terraform apply  #Apply the configuration
terraform destroy #Destroy the configuration
terraform show #Check current state
```

## Setup Azure CLI for Terraform

1. Install the Azure CLI `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`
2. Login to Azure CLI `az login`
3. Check for logged in access to Azure CLI `az account list`
4. If you have multiple subscriptions then setup one subscription `az account set --subscription="SUBSCRIPTION_ID"`
