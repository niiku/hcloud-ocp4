resource "hcloud_server" "lb" {
  name = "lb.${var.cluster_name}.${var.base_domain}"
  image = var.image
  server_type = var.lb_server_type
  keep_disk = true
  location = var.region
  ssh_keys = [
    data.hcloud_ssh_key.ocp4.id]
  user_data = "#cloud-config\nfqdn: lb.${var.cluster_name}.${var.base_domain}\nhostname: lb.${var.cluster_name}.${var.base_domain}"
}

resource "null_resource" "lb_post_deploy" {
  connection {
    host = hcloud_server.lb.ipv4_address
    type = "ssh"
    user = "root"
    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "yum -y install haproxy"]
  }

  provisioner "file" {
    content = data.template_file.lb-haproxy.rendered
    destination = "/etc/haproxy/haproxy.cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl enable haproxy --now"]
  }

}

resource "cloudflare_record" "lb" {
  domain = var.base_domain
  name = "lb.${var.cluster_name}"
  value = hcloud_server.lb.ipv4_address
  type = "A"
  ttl = 120
}

resource "cloudflare_record" "api" {
  domain = var.base_domain
  name = "api.${var.cluster_name}"
  value = hcloud_server.lb.ipv4_address
  type = "A"
  ttl = 120
}
resource "hcloud_rdns" "api" {
  server_id = hcloud_server.lb.id
  ip_address = hcloud_server.lb.ipv4_address
  dns_ptr = cloudflare_record.lb.hostname
}

resource "cloudflare_record" "api-int" {
  domain = var.base_domain
  name = "api-int.${var.cluster_name}"
  value = hcloud_server.lb.ipv4_address
  type = "A"
  ttl = 120
}
resource "hcloud_rdns" "api-int" {
  server_id = hcloud_server.lb.id
  ip_address = hcloud_server.lb.ipv4_address
  dns_ptr = cloudflare_record.lb.hostname
}


resource "cloudflare_record" "apps" {
  domain = var.base_domain
  name = "apps.${var.cluster_name}"
  value = hcloud_server.lb.ipv4_address
  type = "A"
  ttl = 120
}

resource "cloudflare_record" "apps-wildcard" {
  domain = var.base_domain
  name = "*.apps.${var.cluster_name}"
  value = hcloud_server.lb.ipv4_address
  type = "A"
  ttl = 120
}
