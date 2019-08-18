resource "hcloud_ssh_key" "ocp4" {
  name = "ocp4"
  public_key = file("${var.public_key_path}")
}
