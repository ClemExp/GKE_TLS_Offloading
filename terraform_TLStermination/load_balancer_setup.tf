
# create tmp static address which will be later used by the load balancer config on ingress creation
# Note: this is a temp workaround as could not find a way to enable HTTPS termination on ingress creation
#   still useful to create via terraform, as will be destroyed correctly afterwards
resource "google_compute_global_address" "default-tmp" {
  name           = var.lb-static-ip
  address_type   = "EXTERNAL"
  depends_on = [google_container_cluster.primary]
}


# create static address which will be later used by the load balancer config
resource "google_compute_global_address" "default" {
  name           = "traefik-lb-static-ip"
  address_type   = "EXTERNAL"
  depends_on = [google_container_cluster.primary]
}

# Create managed certificate resource
resource "google_compute_managed_ssl_certificate" "managed_certificate" {
  provider = "google-beta"
  project  = var.project

  name      = "tls-cert-off"
  namespace = "tlsoff" 

  managed {
    domains = [
      "traefiktst.clemoregan.com",
      "whoamitst.clemoregan.com"
    ]
    #domains = concat(["${var.backend_name}.${var.domain}."], "${var.alternative-cert-names}")
  }
  depends_on = [google_container_cluster.primary]
}

# # Following creates certificate, but not ideal as may not be removed on terraform destroy
# resource "null_resource" "example_cert" {
#   provisioner "local-exec" {
#     command = <<EOT
# kubectl create -f - -- <<EOF
# apiVersion: networking.gke.io/v1beta1
# kind: ManagedCertificate
# metadata:
#   name: example-certificate
# spec:
#   domains:
#     - example.com
# EOF
# EOT
#   }
# }

resource "kubernetes_ingress" "lb_traefik_ingress" {
  metadata {
    name = "lb-traefik-ingress"
    namespace = "tlsoff"

    annotations {
      "kubernetes.io/ingress.allow-http"                      = "false"
      "networking.gke.io/managed-certificates"                = google_compute_managed_ssl_certificate.managed_certificate.name
      "kubernetes.io/ingress.class"                           = "gce"
      "traefik.ingress.kubernetes.io/frontend-entry-points"   = "https"
      "kubernetes.io/ingress.global-static-ip-name"           = var.lb-static-ip
    }
  }

  spec {
    default_backend {
      service_name = "traefik"
      service_port = 80
    }
  }
  depends_on = [null_resource.traefik_deploy]
}
