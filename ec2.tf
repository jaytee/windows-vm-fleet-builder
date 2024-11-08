data "http" "my_public_ip" {
  url = "http://checkip.amazonaws.com/"
}

locals {
  my_public_ip = trimspace(data.http.my_public_ip.response_body)
}


resource "random_string" "windows_administrator_password" {
  length  = 64
  special = false
}

resource "aws_security_group" "windows_rdp_sg" {
  name_prefix = "windows_rdp_sg"
  description = "Security group for RDP access to Windows VMs"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${local.my_public_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }

  filter {
    name   = "platform"
    values = ["windows"]
  }
}

resource "aws_iam_role" "ssm_role" {
  name               = "windows_ec2_ssm_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_instance" "windows_vms_with_vpn" {
  count         = length(var.openvpn_config_file_urls)
  ami           = data.aws_ami.windows.id
  instance_type = "t3.medium"

  vpc_security_group_ids = [aws_security_group.windows_rdp_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data_with_vpn.ps1", {
    windows_administrator_password = random_string.windows_administrator_password.result
    openvpn_username               = var.openvpn_username
    openvpn_password               = var.openvpn_password
    openvpn_config_file_url        = var.openvpn_config_file_urls[count.index]
  })
}

resource "aws_instance" "windows_vms_without_vpn" {
  count         = var.num_vms_without_vpn
  ami           = data.aws_ami.windows.id
  instance_type = "t3.medium"

  vpc_security_group_ids = [aws_security_group.windows_rdp_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data_without_vpn.ps1", {
    windows_administrator_password = random_string.windows_administrator_password.result
  })
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "windows_ec2_ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}

# Clear the local directory before creating the RDP files
resource "null_resource" "clear_rdp_configs" {
  provisioner "local-exec" {
    command = "find ${path.module}/rdp_configs -type f -name '*.rdp' -exec rm {} + || true"
  }
}

resource "local_file" "rdp_files_for_vpn_instances" {
  count      = length(var.openvpn_config_file_urls)
  depends_on = [aws_instance.windows_vms_with_vpn, null_resource.clear_rdp_configs]

  filename = "${path.module}/rdp_configs/${aws_instance.windows_vms_with_vpn[count.index].public_ip}.rdp"
  content  = <<-EOT
    full address:s:${aws_instance.windows_vms_with_vpn[count.index].public_ip}
    username:s:Administrator
  EOT
}

resource "local_file" "rdp_files_for_non_vpn_instances" {
  count      = var.num_vms_without_vpn
  depends_on = [aws_instance.windows_vms_without_vpn, null_resource.clear_rdp_configs]

  filename = "${path.module}/rdp_configs/${aws_instance.windows_vms_without_vpn[count.index].public_ip}.rdp"
  content  = <<-EOT
    full address:s:${aws_instance.windows_vms_without_vpn[count.index].public_ip}
    username:s:Administrator
  EOT
}
