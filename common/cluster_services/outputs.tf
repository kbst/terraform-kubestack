output "kubeconfig" {
  sensitive = true
  value     = data.template_file.kubeconfig.rendered
}
