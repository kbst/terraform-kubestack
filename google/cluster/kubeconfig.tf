locals {
  kubeconfig = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [
      {
        cluster = {
          server                     = google_container_cluster.current.endpoint
          certificate-authority-data = google_container_cluster.current.master_auth[0].cluster_ca_certificate
        }
        name = google_container_cluster.current.name
      }
    ]
    users = [
      {
        user = {
          token = data.google_client_config.default.access_token
        }
        name = google_container_cluster.current.name
      }
    ]
    contexts = [
      {
        context = {
          cluster = google_container_cluster.current.name
          user    = google_container_cluster.current.name
        }
        name = google_container_cluster.current.name
      }
    ]
    current-context = google_container_cluster.current.name
    preferences     = {}
  })
}
