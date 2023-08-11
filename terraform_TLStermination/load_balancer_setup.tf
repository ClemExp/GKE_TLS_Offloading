
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
# resource "google_compute_managed_ssl_certificate" "managed_certificate" {
#   #provider = "google-beta"
#   project  = var.project

#   name      = "tls-cert-off"
  
#   managed {
#     domains = [
#       "traefiktst.clemoregan.com",
#       "whoamitst.clemoregan.com"
#     ]
#     #domains = concat(["${var.backend_name}.${var.domain}."], "${var.alternative-cert-names}")
#   }
#   depends_on = [google_container_cluster.primary]
# }

# # Following creates certificate, but not ideal as may not be removed on terraform destroy
resource "null_resource" "managed_certificate" {
  provisioner "local-exec" {
    command = <<EOT
kubectl create -f - -- <<EOF
apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: tls-cert-off
  namespace: tlsoff
spec:
  domains:
    - traefik.clemoregan.com
    - whoami.clemoregan.com
    - tlsoff.clemoregan.com
EOF
EOT
  }
  depends_on = [null_resource.monitoring_stack]
}

# following ingress will kick off the automatic creation of the load balancer
resource "null_resource" "lb-ingress" {
  provisioner "local-exec" {
    command = <<EOT
kubectl create -f - -- <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: lb-traefik-ingress
  namespace: tlsoff
  annotations:
    networking.gke.io/managed-certificates: tls-cert-off
    kubernetes.io/ingress.class: gce # Although deprecated by kubernetes spec, GKE still uses this, so must be used
    traefik.ingress.kubernetes.io/frontend-entry-points: "https"
    kubernetes.io/ingress.global-static-ip-name: "traefik-lb-static-ip-tmp"
spec:
  defaultBackend:
    service:
      name: traefik
      port:
        number: 80
EOF
EOT
  }
  depends_on = [null_resource.managed_certificate]
}

# resource "kubernetes_ingress" "lb_traefik_ingress" {
#   metadata {
#     name          = "lb-traefik-ingress"
#     namespace     = "tlsoff"
#     annotations   = {
#       "networking.gke.io/managed-certificates"                = google_compute_managed_ssl_certificate.managed_certificate.name
#       "kubernetes.io/ingress.class"                           = "gce"
#       "traefik.ingress.kubernetes.io/frontend-entry-points"   = "https"
#       "kubernetes.io/ingress.global-static-ip-name"           = var.lb-static-ip
#     }
#   }

#   spec {
#     rule {
#       http {
#         path {
#           path = "/*"
#           backend {
#             service_name = "traefik"
#             service_port = 80            
#           }
#         }
#       }
#     }
#   }
#   depends_on = [null_resource.traefik_deploy]
# }
