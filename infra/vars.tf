variable "region" {
  type    = string
  default = "us-central"
}

variable "name" {
  type        = string
  description = "Name of the project, vpc and prefix for all resources"
  default     = "subtensor-cluster"
}

variable "image" {
  type        = string
  description = "Image to use for all nodes"
  default     = "linode/ubuntu24.04"
}

variable "size" {
  type        = string
  description = "Size of the nodes"
  default     = "g6-standard-4"
}

variable "proxy_size" {
  type        = string
  description = "Size of the haproxy node"
  default     = "g6-standard-1"
}

variable "number_of_nodes" {
  type        = number
  description = "Number of nodes to create"
  default     = 3
}

variable "ssh_keys" {
  type        = list(string)
  description = "List of SSH keys to use for all nodes"
}

variable "port" {
  type        = number
  description = "Port to use for the frontend"
  default     = 9944
}

variable "protocol" {
  type        = string
  description = "Protocol to use for the frontend"
  default     = "http"
}

variable "ssl_certificate" {
  type        = string
  description = "SSL certificate to use for the frontend"
  default     = null
}

variable "ssl_certificate_key" {
  type        = string
  description = "SSL certificate key to use for the frontend"
  default     = null
}