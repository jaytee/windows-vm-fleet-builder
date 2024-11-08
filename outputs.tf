output "windows_vms_with_vpn" {
  value = {
    for idx, instance in aws_instance.windows_vms_with_vpn : instance.id => {
      ip       = instance.public_ip
      port     = 3389
      username = "Administrator"
      password = random_string.windows_administrator_password.result
    }
  }
  description = "Information for each Windows VM including public IP, RDP port, username, and password"
}

output "windows_vms_without_vpn" {
  value = {
    for idx, instance in aws_instance.windows_vms_without_vpn : instance.id => {
      ip       = instance.public_ip
      port     = 3389
      username = "Administrator"
      password = random_string.windows_administrator_password.result
    }
  }
  description = "Information for each Windows VM including public IP, RDP port, username, and password"
}
