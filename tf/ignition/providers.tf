provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  email = var.cf_email
  token = var.cf_token
}