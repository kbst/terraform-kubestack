module "eks_zero" {
  providers = {
    aws = "aws.eks_zero"
  }

  source = "github.com/kbst/terraform-kubestack//aws/cluster?ref={{version}}"

  configuration = var.clusters["eks_zero"]
}
