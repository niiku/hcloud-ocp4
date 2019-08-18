output "dns-verify-script" {
  value = data.template_file.reboot-script.rendered
}


output "reboot-script" {
  value = data.template_file.reboot-script.rendered
}

