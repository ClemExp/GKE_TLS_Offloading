
# Following ingress routes are to publish access to monitoring tools through traefik
# resource "null_resource" "grafana_ingress_route" {
#   provisioner "local-exec" {
#     command = <<EOT
# kubectl create -f - -- <<EOF
# apiVersion: traefik.containo.us/v1alpha1
# kind: IngressRoute
# metadata:
#   name: grafana-ingress-route
# spec:
#   entryPoints:
#     - web
#   routes:
#     - match: Host(`grafana.clemoregan.com`) && (PathPrefix(`/`))
#       kind: Rule
#       services:
#       - kind: Service
#         name: prometheus-stack-grafana
#         port: 80
# EOF
# EOT
#   }
#   depends_on = [null_resource.monitoring_stack]
# }

# resource "null_resource" "prometheus_ingress_route" {
#   provisioner "local-exec" {
#     command = <<EOT
# kubectl create -f - -- <<EOF
# apiVersion: traefik.containo.us/v1alpha1
# kind: IngressRoute
# metadata:
#   name: prometheus-ingress-route
# spec:
#   entryPoints:
#     - web
#   routes:
#     - match: Host(`prom.clemoregan.com`) && (PathPrefix(`/`))
#       kind: Rule
#       services:
#       - kind: Service
#         name: prometheus-stack-kube-prom-prometheus
#         port: 9090
# EOF
# EOT
#   }
#   depends_on = [null_resource.monitoring_stack]
# }

# resource "kubernetes_manifest" "grafana_ingress_route" {
#   depends_on = [null_resource.monitoring_stack]

#   manifest = {
#     apiVersion = "traefik.containo.us/v1alpha1"
#     kind       = "IngressRoute"
#     metadata = {
#       name      = "prometheus-ingress-route"
#     }
#     spec = {
#       entryPoints = [
#         "web"
#       ]
#       routes = [
#         {
#           match = "Host(`grafana.clemoregan.com`) && (PathPrefix(`/`))"
#           kind  = "Rule"
#           services = [
#             {
#               name = "prometheus-stack-grafana"
#               kind = "Service"
#               port = 80
#             }
#           ]
#         }
#       ]
#     }
#   }
# }

resource "kubectl_manifest" "grafana_ingress_route" {
  yaml_body = "${file("../ingress_access/grafana.yaml")}"
}

resource "kubectl_manifest" "prometheus_ingress_route" {
  yaml_body = "${file("../ingress_access/prometheus.yaml")}"
}