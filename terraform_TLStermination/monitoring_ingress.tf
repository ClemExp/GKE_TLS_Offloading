
# Following ingress routes are to publish access to monitoring tools through traefik
resource "kubectl_manifest" "grafana_ingress_route" {
  yaml_body = "${file("../ingress_access/grafana.yaml")}"
  depends_on = [null_resource.monitoring_stack]
}

resource "kubectl_manifest" "prometheus_ingress_route" {
  yaml_body = "${file("../ingress_access/prometheus.yaml")}"
  depends_on = [null_resource.monitoring_stack]
}