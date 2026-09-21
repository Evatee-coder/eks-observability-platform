# Dev
## Terraform init

# use to check your backend config file where you configure your S3 backend
terraform init -backend-config=vars/dev.tfbackend    

# you're checking your environment file
terraform plan -var-file=vars/dev.tfvars

terraform apply -var-file=vars/dev.tfvars

# prod
## Terraform init

terraform init -backend-config=vars/prod.tfbackend

terraform plan -var-file=vars/prod.tfvars

terraform apply -var-file=vars/prod.tfvars