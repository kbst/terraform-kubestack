output "kubeconfig" {
  value = data.template_file.kubeconfig.rendered
}

output "kubeconfig_dummy" {
  value = data.template_file.kubeconfig_dummy.rendered
}

output "default_ingress_ip" {
  value = length(google_compute_address.current) > 0 ? google_compute_address.current[0].address : null
}
