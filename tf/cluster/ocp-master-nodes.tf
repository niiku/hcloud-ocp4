resource "hcloud_server" "master" {
  count = var.master_count
  name = "master${count.index}.${var.cluster_name}.${var.base_domain}"
  image = var.image
  server_type = var.master_server_type
  keep_disk = true
  location = var.region
  ssh_keys = [
    data.hcloud_ssh_key.ocp4.id]
}

resource "null_resource" "master_post_deploy" {
  count = var.master_count
  connection {
    host = hcloud_server.master[count.index].ipv4_address
    type = "ssh"
    user = "root"
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    content = data.template_file.grub-master.rendered
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

resource "cloudflare_record" "master" {
  count = var.master_count
  domain = var.base_domain
  name = "master${count.index}.${var.cluster_name}"
  value = hcloud_server.master[count.index].ipv4_address
  type = "A"
  ttl = 120
}

resource "hcloud_rdns" "master" {
  count = var.master_count
  server_id = hcloud_server.master[count.index].id
  ip_address = hcloud_server.master[count.index].ipv4_address
  dns_ptr = cloudflare_record.master[count.index].hostname
}

resource "cloudflare_record" "etcd" {
  count = var.master_count
  domain = var.base_domain
  name = "etcd-${count.index}.${var.cluster_name}"
  value = hcloud_server.master[count.index].ipv4_address
  type = "A"
  ttl = 120
}

resource "cloudflare_record" "etcd-srv" {
  count = var.master_count
  domain = var.base_domain
  name   = "_etcd-server-ssl._tcp.${var.cluster_name}"
  type   = "SRV"

  data = {
    service  = "_etcd-server-ssl"
    proto    = "_tcp"
    name     = "ocp"
    priority = 0
    weight   = 10
    port     = 2380
    target   = cloudflare_record.etcd[count.index].hostname
  }
}
