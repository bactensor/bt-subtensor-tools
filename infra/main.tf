terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
    }

    random = {
      source  = "hashicorp/random"
    }
  }
}

provider "linode" {}

# generate random password for root user
resource "random_password" "root" {
  length = 32
}

resource "linode_instance" "self" {
  count             = var.number_of_nodes
  label             = "${var.name}-${count.index}"
  region            = var.region
  image             = var.image
  type              = var.size

  authorized_keys   = var.ssh_keys
  root_pass         = random_password.root.result
  private_ip        = true

  lifecycle {
    create_before_destroy = false
  }
}

resource "linode_nodebalancer" "self" {
  label             = "${var.name}-frontend"
  region            = var.region
}

resource "linode_nodebalancer_config" "self" {
  nodebalancer_id = linode_nodebalancer.self.id
  port            = var.port
  check           = "connection"
  protocol        = var.protocol
  algorithm       = "roundrobin"
  ssl_cert        = var.ssl_certificate
  ssl_key         = var.ssl_certificate_key
}

resource "linode_nodebalancer_node" "self" {
  count           = var.number_of_nodes
  nodebalancer_id = linode_nodebalancer.self.id
  config_id       = linode_nodebalancer_config.self.id
  label           = "${var.name}-node-${count.index}"
  address         = "${linode_instance.self[count.index].private_ip_address}:${var.port}"
}

module "ansible_provisioner" {
  depends_on = [linode_instance.self]
  source    = "github.com/cloudposse/tf_ansible"

  arguments = ["--user=root --ssh-extra-args='-o StrictHostKeyChecking=no'"]
  envs      = ["hosts=${join(",", linode_instance.self[*].ip_address)}"]
  playbook  = "ansible/subtensor.yaml"
  dry_run   = false
}