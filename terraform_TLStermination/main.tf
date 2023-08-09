terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region = var.region
  zone = var.zone
}

resource "google_container_cluster" "primary" {
  name = "tlsoffloading-cluster"
  location = var.zone
  initial_node_count = var.numberOfNodes

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  cluster_autoscaling {
    enabled = false
  }

  node_config {
    // using gke-default
    // https://cloud.google.com/sdk/gcloud/reference/container/node-pools/create#--scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

  }
}

data "google_client_config" "current" {}


provider "helm" {

  kubernetes {
    host = google_container_cluster.primary.endpoint
    token = data.google_client_config.current.access_token
    client_certificate = base64decode(google_container_cluster.primary.master_auth.0.client_certificate)
    client_key = base64decode(google_container_cluster.primary.master_auth.0.client_key)
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }
}


# resource "helm_release" "traefik" {
#   name = "traefik"
#   chart = "traefik"
#   repository = "https://helm.traefik.io/traefik"
#   namespace = "traefik"
#   create_namespace = true

#   depends_on = [null_resource.cluster_tls]

#   values = [
#     "${file("../helm/deployable_apps/traefik_values.yaml")}",
#   ]
#   # or can paste full file (replaceing ..): values = [<<EOF ... EOF]
# }

# resource "helm_release" "cert-manager" {
#   name = "cert-manager"
#   chart = "cert-manager"
#   repository = "https://charts.jetstack.io"
#   namespace = "cert-manager"
#   create_namespace = true

#   set {
#     name  = "installCRDs"
#     value = "true"
#   }
# }

provider "kubernetes" {
    host = google_container_cluster.primary.endpoint
    token = data.google_client_config.current.access_token
    client_certificate = base64decode(google_container_cluster.primary.master_auth.0.client_certificate)
    client_key = base64decode(google_container_cluster.primary.master_auth.0.client_key)
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

# resource "kubernetes_secret" "dns-secret" {
#   metadata {
#     name = "google-dns-sa"
#     namespace = "default"
#   }
#   depends_on = [helm_release.cert-manager]
#   data = {
#     "key.json" = file(var.google_dns_sa_file)
#   }
# }
