output "ids" {
  value = data.kustomization_overlay.current.ids
}

output "ids_prio" {
  value = data.kustomization_overlay.current.ids_prio
}

output "manifests" {
  value = data.kustomization_overlay.current.manifests
}
