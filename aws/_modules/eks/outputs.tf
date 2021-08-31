output "kubeconfig" {
  value = data.template_file.kubeconfig.rendered
}

output "kubeconfig_dummy" {
  value = data.template_file.kubeconfig_dummy.rendered
}
