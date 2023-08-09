# Create service for traefik metrics - which will be scraped my monitoring tools
resource "null_resource" "monitoring_metrics" {

  depends_on = [null_resource.traefik_deploy]

  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
    command = <<EOT
      set -e
      echo 'Applying Metrics service for prometheus...'
      kubectl apply -f ../monitoring_setup/traefik-metrics-service.yaml
    EOT
  }
}

# Local shell deploy of exisitng traefik chart - injecting environment = subdomain
resource "null_resource" "monitoring_stack" {

  depends_on = [null_resource.monitoring_metrics]

  provisioner "local-exec" {
    command = "helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack -f ../monitoring_setup/stack-promo-grafana-values.yaml"
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
  }
}