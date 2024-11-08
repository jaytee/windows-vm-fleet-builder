variable "openvpn_config_file_urls" {
  description = "OpenVPN configuration files to generate Windows VMs for"
  type        = list(string)
  default     = []
}

variable "openvpn_username" {
  description = "Username for VPN account"
  type        = string
  default     = null
}

variable "openvpn_password" {
  description = "Password for VPN account"
  type        = string
  default     = null
}

variable "num_vms_without_vpn" {
  description = "Number of EC2s to create without VPN configurations"
  type        = number
  default     = 0
}
