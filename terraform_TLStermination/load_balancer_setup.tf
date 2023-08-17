
# create static address which will be used by the load balancer config
resource "google_compute_global_address" "default" {
  name           = "traefik-lb-static-ip"
  address_type   = "EXTERNAL"
  depends_on = [google_container_cluster.primary]
}

# # Following creates certificate, but not ideal as may not be removed on terraform destroy
# Creation via resource "google_compute_managed_ssl_certificate" "managed_certificate" not working as expected
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
    - grafana.clemoregan.com
    - prom.clemoregan.com
EOF
EOT
  }
  depends_on = [null_resource.monitoring_stack]
}

# following ingress will kick off the automatic creation of the load balancer
# Creation via resource "kubernetes_ingress" "lb_traefik_ingress" not working as expected
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
    kubernetes.io/ingress.global-static-ip-name: "traefik-lb-static-ip"
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
