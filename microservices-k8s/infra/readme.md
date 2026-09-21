
# Dev
## Terraform init

terraform init -backend-config=vars/dev.tfbackend

terraform plan -var-file=vars/dev.tfvars

terraform apply -var-file=vars/dev.tfvars


# prod
## Terraform init

terraform init -backend-config=vars/prod.tfbackend


terraform plan -var-file=vars/prod.tfvars

terraform apply -var-file=vars/prod.tfvars



# conect to eks cluster from local

aws eks update-kubeconfig --name prod-microservices-ekscluster

kubectl config rename-context <arn..clusterName> <newName>


start cluster via github
start eks services via github
apply terraform to microservices folder to create ecr repos (4) of them
use github ms build to build image and push them to the ecr repos part1
apply ingress-dns.tf
use argocd to deploy the apps


to destroy
first delete the argocd apps
destroy the microservices infra using tf
destroy the eks_services via github
destroy the cluster via github                               
