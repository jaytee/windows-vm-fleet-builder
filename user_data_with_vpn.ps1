<powershell>

net user Administrator "${windows_administrator_password}"

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install googlechrome -y
choco install openvpn -y

$openVpnAuthUserPassPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), 'auth_user_pass.txt')
$openVpnAuthUserPassContents = "${openvpn_username}`r`n${openvpn_password}"
Set-Content -Path $openVpnAuthUserPassPath -Value $openVpnAuthUserPassContents

$shortcutPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "Check IPInfo.url")
$shortcutContent = @"
[InternetShortcut]
URL=https://ipinfo.io/city
"@
Set-Content -Path $shortcutPath -Value $shortcutContent -Encoding ASCII

$openVpnConfigPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), 'config.ovpn')
Invoke-WebRequest -Uri "${openvpn_config_file_url}" -OutFile $openVpnConfigPath

Start-Process -FilePath "C:\Program Files\OpenVPN\bin\openvpn.exe" -ArgumentList "--config", $openVpnConfigPath, "--auth-user-pass", $openVpnAuthUserPassPath

</powershell>