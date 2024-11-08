<powershell>

net user Administrator "${windows_administrator_password}"

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install googlechrome -y
choco install openvpn -y

$shortcutPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "Check IPInfo.url")
$shortcutContent = @"
[InternetShortcut]
URL=https://ipinfo.io/city
"@
Set-Content -Path $shortcutPath -Value $shortcutContent -Encoding ASCII

</powershell>