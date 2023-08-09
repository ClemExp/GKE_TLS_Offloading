# Infrastructure as Code for GKE cluster management & base application deployment

Terraform configuration included here will manage the following infrastructure:
- Create a multi-node GKE cluster. We will create a standard kubernetes cluster, where we will manage the infrastructure worker nodes, rahter than the google serverless model. The number of nodes we require for our cluster can be configured as needs be.
- Reconfigure kubeconfig to interact with the newly created cluster
- Setup core namespaces and secrets for importing self managed certificates into the cluster
- Import certificates into GCP automatically to be used in load balancer creation
- Create static IP(s) for DNS integration & validation
- Install key applications for our lab via Terraform helm provider:
    - Traefik (ingress controller & reverse proxy)
    - Cert-manager (for management of let's encrypt certificates)
    - Monitoring tools ***

## GKE cluster management prerequisites

Pre-requisites to creating cluster via terraform:
- Create base GCP project where cluster will be deployed
- Terraform installed on client machine
- Create service account for terraform
- Create service account for DBS administrator for DNS validation
- Download both service account jsons which terraform can read while creating GKE cluster
- gcloud CLI installed to connect to cluster after cluster creation

## Terraform commands

We will use the following standard terraform commands:
- terraform init
- terraform plan
- terraform apply
- terraform destroy

More details on commands can be referenced here: https://developer.hashicorp.com/terraform/cli/commands

## GKE cluster specification setup

We will use a terraform.tfvars file (sample included here), to inject key variables into the terraform cluster creation, specifying the service account details and GCP project for our cluster; For example:

```
credentials_file = "tls-terraform-main.json"
google_dns_sa_file = "tls-terraform-dns.json"
project = "tls-terraform"

```

Additional variables can be configured in variable.tf & outputs.tf

## GKE cluster creation

Our cluster configuration is stored in main.tf. To modify cluster name and number of cluster nodes to be deployed we can modify this directly in the main.tf:

```
resource "google_container_cluster" "primary" {
  name = "playground-cluster"
  location = var.zone
  initial_node_count = 2

```

After terraform init, run the terraform apply command to create the cluster:

```
terraform apply -var-file="terraform.tfvars"
```

After some 5-10 minutes terraform will finish operation and we can view our cluster and pod details.

```
kubectl get deploy,svc -n traefik
```

## Clean up
To manage cloud infrastructure costs, perform a terraform destroy when cluster is not being used..

```
cd terraform
terraform destroy
```
