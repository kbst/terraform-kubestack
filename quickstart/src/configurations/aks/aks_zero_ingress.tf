module "aks_zero_nginx" {
  providers = {
    kustomization = kustomization.aks_zero
  }
  source  = "kbst.xyz/catalog/nginx/kustomization"
  version = "0.46.0-kbst.1"

  configuration = {
    apps = {
      patches = [{
        patch = <<-EOF
          apiVersion: v1
          kind: Service
          metadata:
            name: ingress-nginx-controller
            namespace: ingress-nginx
          spec:
            loadBalancerIP: ${module.aks_zero.default_ingress_ip}
        EOF
      }]
    }

    ops = {}

    loc = {}
  }
}
