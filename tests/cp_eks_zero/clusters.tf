module "eks_zero" {
  providers = {
    aws = "aws.eks_zero"
  }

  source = "../../aws/cluster"

  configuration = var.clusters["eks_zero"]
}
