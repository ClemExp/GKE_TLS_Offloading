# Creating namespace and secret for traefik & applications: for custom or services apps
resource "null_resource" "cluster_post_create" {

  depends_on = [null_resource.establish_cluster]

  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
    command = <<EOT
      set -e
      echo 'Creating kubernetes resources kubectl...'
      kubectl create namespace tlsoff
    EOT
  }
}

# First ensure that we are pointing to the correct cluster - reconfiguring kubeconfig
resource "null_resource" "establish_cluster" {
  depends_on = [google_container_cluster.primary]

  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
    command = <<EOT
      set -e
      echo 'Reconfiguring kubeconfig...'
      gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --zone $(terraform output -raw zone) --project $(terraform output -raw project)
    EOT
  }
}

# create static address which will be later used by the load balancer config
resource "google_compute_global_address" "default" {
  name           = "traefik-lb-static-ip"
  address_type   = "EXTERNAL"
}