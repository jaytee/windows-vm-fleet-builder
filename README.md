# Windows VM Fleet Builder

Scales out _n_ Windows EC2 instances, optionally configuring them with OpenVPN.

### Setup

Install [Hermit](https://cashapp.github.io/hermit/usage/get-started/), a package manager used for managing the Terraform version.

Install a Windows Remote Desktop client that you can use to RDP into the VMs:

- **macOS:** https://apps.apple.com/us/app/windows-app/id1295203466?mt=12

Next, create a custom \*.tfvars file using `example.tfvars` as a base. Any VPN provider should work with OpenVPN, but it has been tested with NordVPN only.

NordVPN's OpenVPN configs can be found [here](https://nordvpn.com/ovpn/). Copy the TCP version download links into the Terraform config.

```sh
❯ source ./bin/activate-hermit
❯ terraform init
❯ terraform apply -var-file=<my_vars>.tfvars -auto-approve
```

Once the VMs have been created, locate the generated \*.rdp files in `./rdp_configs` which, assuming your RDP client can open RDP files, should be the quickest way to launch each VM.

The password for the `Administrator` user is output by the `terraform apply` step, alongside the IP address of the VM if you're not using the RDP files to connect.

The Desktop has some files created automatically:

- A _"Check IPInfo"_ shortcut to check which city your IP is geolocated nearest.
- The username/password file for connecting to the VPN.

### Cleanup

```sh
❯ terraform destroy -auto-approve
```
