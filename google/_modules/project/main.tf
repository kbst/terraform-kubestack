resource "google_project" "current" {
  name            = "${var.metadata_name}"
  project_id      = "${var.metadata_name}"
  billing_account = "00F821-04C020-D24F7A"
  skip_delete     = true
}

resource "google_project_service" "project" {
  count              = "${length(var.services)}"
  project            = "${google_project.current.name}"
  service            = "${var.services[count.index]}"
  disable_on_destroy = false
}
