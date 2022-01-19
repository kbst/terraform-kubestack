module "eks_zero_rbac" {
  providers = {
    kustomization = kustomization.eks_zero
  }

  source  = "kbst.xyz/catalog/custom-manifests/kustomization"
  version = "0.1.0"

  configuration = {
    apps = {
      resources = [
        "${path.root}/manifests/eks_zero_rbac/cluster_role_binding_system_masters.yaml"
      ]
    }

    ops = {}

    loc = {}
  }
}
