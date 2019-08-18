resource "hcloud_server" "bootstrap" {
  name = "bootstrap.${var.cluster_name}.${var.base_domain}"
  image = var.image
  server_type = var.bootstrap_server_type
  keep_disk = true
  location = var.region
  ssh_keys = [
    data.hcloud_ssh_key.ocp4.id]
}

resource "null_resource" "bootstrap_post_deploy" {
  connection {
    host = hcloud_server.bootstrap.ipv4_address
    type = "ssh"
    user = "root"
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    content = data.template_file.grub-bootstrap.rendered
    destination = "/etc/grub.d/40_custom"
  }

  provisioner "remote-exec" {
    inline = [
    "curl http://ignition.${var.cluster_name}.${var.base_domain}/rhcos-installer-kernel -o /boot/rhcos-installer-kernel",
    "curl http://ignition.${var.cluster_name}.${var.base_domain}/rhcos-initramfs.img -o /boot/rhcos-initramfs.img",
    "grub2-set-default 2",
    "grub2-mkconfig --output=/boot/grub2/grub.cfg",
    ]
  }
}

resource "cloudflare_record" "bootstrap" {
  domain = var.base_domain
  name = "bootstrap.${var.cluster_name}.${var.base_domain}"
  value = hcloud_server.bootstrap.ipv4_address
  type = "A"
  ttl = 120
}

resource "hcloud_rdns" "bootstrap" {
  server_id = hcloud_server.bootstrap.id
  ip_address = hcloud_server.bootstrap.ipv4_address
  dns_ptr = cloudflare_record.bootstrap.hostname
}