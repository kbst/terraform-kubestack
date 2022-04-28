module "gke_zero_nginx" {
  providers = {
    kustomization = kustomization.gke_zero
  }
  source  = "test.kbst.xyz/catalog/nginx/kustomization"
  version = "1.1.3-kbst.1"

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
            loadBalancerIP: ${module.gke_zero.default_ingress_ip}
        EOF
      }]

      replicas = [{
        name  = "ingress-nginx-controller"
        count = 1
      }]
    }

    ops = {}

    loc = {}
  }
}
