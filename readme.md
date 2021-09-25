## Terraform-Azure Template

Deploy resources to Azure with Terraform

### Resources:

1. Create a virtual network
2. Create a subnet
3. Create a public IP address
4. Create a network security group
5. Create a virtual network interface card
6. Create a storage account for diagnostics
7. Create a virtual machine
8. Delete a virtual machine after submitting the assignment

### Prerequisite:

- az login
- az account set --subscription "subscription_id"
- terraform init
- terraform plan
- terraform apply (for creating all the resources)
- terraform destroy (for destroying all the resources once you done playing)
- terraform destroy -target RESOURCE_TYPE.NAME (for destroying a particular resource)
