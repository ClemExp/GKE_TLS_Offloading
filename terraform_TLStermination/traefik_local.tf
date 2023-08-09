# Local shell deploy of exisitng traefik chart - injecting environment = subdomain
resource "null_resource" "traefik_deploy" {

  depends_on = [null_resource.cluster_post_create]

  provisioner "local-exec" {
    command = "helm install traefik ../helm/traefik-offloading --values ../helm/traefik-offloading/values.yaml --set varsubdomain='clemoregan.com' -n tlsoff --create-namespace"
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
  }
}