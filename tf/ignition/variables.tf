#
# General variables
#

variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type = "string"
}

variable "cf_email" {
  description = "Cloudflare Account Email"
  type = "string"
}

variable "cf_token" {
  description = "Cloudflare API Token"
  type = "string"
}

variable "image" {
  type = "string"
  default = "centos-7"
}

variable "region" {
  description = "Create nodes in this regions"
  type = string
  default = "fsn1"
}

variable "base_domain" {
  description = "Base domain for the cluster"
  type = string
}

variable cluster_name {
  type = "string"
  default = "ocp"
}

variable "public_key_path" {
  description = "Path to the public key to access OCP4 nodes"
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  description = "Path to the private key to access OCP4 nodes"
  type = string
  default = "~/.ssh/id_rsa"
}

#
# Ignition variables
#

variable ignition_server_type {
  type = "string"
  default = "cx11-ceph"
}

variable "openshift_installer_dir" {
  type = "string"
  default = "~/ocp4/installer/"
}

#
# Cluster variables
#

variable bootstrap_server_type {
  type = "string"
  default = "cx21-ceph"
}

variable lb_server_type {
  type = "string"
  default = "cx11-ceph"
}

variable master_server_type {
  type = "string"
  default = "cx21-ceph"
}

variable worker_server_type {
  type = "string"
  default = "cx21-ceph"
}

variable "master_count" {
  description = "Master node count"
  type = number
  default = 3
}

variable "worker_count" {
  description = "Compute node count"
  type = number
  default = 2
}