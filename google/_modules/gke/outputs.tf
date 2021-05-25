output "kubeconfig" {
  value = data.template_file.kubeconfig.rendered
}

output "default_ingress_ip" {
  value = length(google_compute_address.current) > 0 ? google_compute_address.current[0].address : null
}
