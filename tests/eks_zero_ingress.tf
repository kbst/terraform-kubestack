module "eks_zero_nginx" {
  providers = {
    kustomization = kustomization.eks_zero
  }
  source  = "test.kbst.xyz/catalog/nginx/kustomization"
  version = "1.1.3-kbst.1"

  configuration = {
    apps = {
      replicas = [{
        name  = "ingress-nginx-controller"
        count = 1
      }]
    }

    ops = {}

    loc = {}
  }
}

module "eks_zero_dns_zone" {
  providers = {
    aws        = aws.eks_zero
    kubernetes = kubernetes.eks_zero
  }

  source = "../aws/cluster/elb-dns"

  ingress_service_name      = "ingress-nginx-controller"
  ingress_service_namespace = "ingress-nginx"

  metadata_fqdn = module.eks_zero.current_metadata["fqdn"]
}
