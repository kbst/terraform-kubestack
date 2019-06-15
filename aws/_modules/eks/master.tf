resource "aws_eks_cluster" "current" {
  name     = "${var.metadata_name}"
  role_arn = "${aws_iam_role.master.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.masters.id}"]
    subnet_ids         = ["${aws_subnet.current.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.master_cluster_policy",
    "aws_iam_role_policy_attachment.master_service_policy",
  ]
}
