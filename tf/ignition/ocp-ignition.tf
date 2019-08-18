resource "hcloud_server" "ignition" {
  name = "ignition.${var.cluster_name}.${var.base_domain}"
  image = var.image
  server_type = var.ignition_server_type
  keep_disk = true
  location = var.region
  ssh_keys = [
    hcloud_ssh_key.ocp4.id]
}

resource "null_resource" "ignition_post_deploy" {
  connection {
    host = hcloud_server.ignition.ipv4_address
    type = "ssh"
    user = "root"
    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "yum -y install httpd",
      "systemctl enable httpd --now",
    ]
  }

/*  provisioner "remote-exec" {
    inline = [
      "curl ${var.rhcos_installer_kernel} -o /var/www/html/rhcos-installer-kernel",
      "curl ${var.rhcos_installer_initramfs} -o /var/www/html/rhcos-initramfs.img",
      "curl ${var.rhcos_metal_bios} -o /var/www/html/rhcos-metal-bios.raw.gz",
    ]
  }*/

  provisioner "file" {
    source = "${var.openshift_installer_dir}bootstrap.ign"
    destination = "/var/www/html/bootstrap.ign"
  }

  provisioner "file" {
    source = "${var.openshift_installer_dir}master.ign"
    destination = "/var/www/html/master.ign"
  }

  provisioner "file" {
    source = "${var.openshift_installer_dir}worker.ign"
    destination = "/var/www/html/worker.ign"
  }
}

resource "cloudflare_record" "ignition" {
  domain = var.base_domain
  name = "ignition.${var.cluster_name}.${var.base_domain}"
  value = hcloud_server.ignition.ipv4_address
  type = "A"
  ttl = 120
}

resource "hcloud_rdns" "ignition" {
  server_id = hcloud_server.ignition.id
  ip_address = hcloud_server.ignition.ipv4_address
  dns_ptr = cloudflare_record.ignition.hostname
}