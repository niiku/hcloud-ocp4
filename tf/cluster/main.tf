data "hcloud_ssh_key" "ocp4" {
  name = "ocp4"
}

data "template_file" "lb-haproxy" {
  template = file("${path.module}/tpl/haproxy.cfg.tpl")
  vars = {
    master_hostnames = join(",", hcloud_server.master.*.name)
    worker_hostnames = join(",", hcloud_server.worker.*.name)
    bootstrap_hostname = "ignition.${var.cluster_name}.${var.base_domain}"
  }
}

data "template_file" "grub-bootstrap" {
  template = file("${path.module}/tpl/40_custom.tpl")
  vars = {
    ignition_hostname = "ignition.${var.cluster_name}.${var.base_domain}"
    server_role = "bootstrap"
  }
}

data "template_file" "grub-master" {
  template = file("${path.module}/tpl/40_custom.tpl")
  vars = {
    ignition_hostname = "ignition.${var.cluster_name}.${var.base_domain}"
    server_role = "master"
  }
}

data "template_file" "grub-worker" {
  template = file("${path.module}/tpl/40_custom.tpl")
  vars = {
    ignition_hostname = "ignition.${var.cluster_name}.${var.base_domain}"
    server_role = "worker"
  }
}

data "template_file" "reboot-script" {
  template = file("${path.module}/tpl/reboot.sh.tpl")
  vars = {
    private_key_path = var.private_key_path
    nodes = "bootstrap.${var.cluster_name}.${var.base_domain},${join(",", hcloud_server.master.*.name)},${join(",", hcloud_server.worker.*.name)}"
  }
}

