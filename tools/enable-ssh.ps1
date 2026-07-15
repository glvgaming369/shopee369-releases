# Shopee369 — cai/sua OpenSSH Server (offline, idempotent, robust).
# Chay trong PowerShell Administrator, hoac 1 dong:
#   irm https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/enable-ssh.ps1 | iex
$ErrorActionPreference = 'SilentlyContinue'
Write-Host '=== Shopee369 SSH setup ===' -ForegroundColor Cyan

$OSSH = "$env:ProgramFiles\OpenSSH-Win64"

# 1) Chua co binaries -> tai offline tu GitHub (khong can Windows Update)
if (-not (Test-Path "$OSSH\sshd.exe")) {
  $zip = "$env:TEMP\OpenSSH-Win64.zip"
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Write-Host '[*] Tai OpenSSH-Win64...'
  Invoke-WebRequest 'https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.5.0.0p1-Beta/OpenSSH-Win64.zip' -OutFile $zip
  Expand-Archive $zip "$env:ProgramFiles" -Force
}

# 2) Thu muc + FILE CONFIG (ban offline KHONG tao san sshd_config -> sshd thoat ngay)
$SSHDATA = "$env:ProgramData\ssh"
New-Item -ItemType Directory -Force $SSHDATA | Out-Null
if (-not (Test-Path "$SSHDATA\sshd_config")) { Copy-Item "$OSSH\sshd_config_default" "$SSHDATA\sshd_config" -Force }

# 3) Host keys
Write-Host '[*] Tao host keys...'
& "$OSSH\ssh-keygen.exe" -A | Out-Null

# 4) SIET QUYEN tat ca host key + config (sshd duoi SYSTEM thoat neu quyen ho)
foreach ($k in Get-ChildItem "$SSHDATA\ssh_host_*_key" -ErrorAction SilentlyContinue) {
  icacls $k.FullName /inheritance:r /grant 'SYSTEM:F' /grant 'Administrators:F' | Out-Null
}
icacls "$SSHDATA\sshd_config" /inheritance:r /grant 'SYSTEM:F' /grant 'Administrators:F' /grant 'Authenticated Users:RX' | Out-Null

# 5) Public key ky thuat (Shopee369)
$AK  = "$SSHDATA\administrators_authorized_keys"
$PUB = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFi1Ck1a2meO28JQUhOSadTQ739qwreXLDApdM2MqvO shopee369-deploy'
if (-not (Test-Path $AK) -or -not (Select-String $AK -Pattern 'shopee369-deploy' -Quiet)) { Add-Content $AK $PUB }
icacls $AK /inheritance:r /grant 'Administrators:F' /grant 'SYSTEM:F' | Out-Null

# 6) Firewall cong 22 (ca netsh + cmdlet)
& netsh advfirewall firewall delete rule name='OpenSSH-Server-In-TCP' | Out-Null
& netsh advfirewall firewall add rule name='OpenSSH-Server-In-TCP' dir=in action=allow protocol=TCP localport=22 profile=any | Out-Null
New-NetFirewallRule -DisplayName 'OpenSSH-Server-In-TCP' -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow -Profile Any -ErrorAction SilentlyContinue | Out-Null

# 7) Tao SERVICE sshd THU CONG bang sc.exe (install-sshd.ps1 hay loi im lang) — chay duoi LocalSystem
if (Get-Service sshd -ErrorAction SilentlyContinue) { Stop-Service sshd -Force; & sc.exe delete sshd | Out-Null; Start-Sleep 1 }
& sc.exe create sshd binPath= "$OSSH\sshd.exe" start= auto obj= LocalSystem DisplayName= "OpenSSH SSH Server" | Out-Null
& sc.exe failure sshd reset= 86400 actions= restart/5000/restart/5000/restart/5000 | Out-Null
Start-Service sshd
Start-Sleep 3

# 8) Ket qua
$svc = (Get-Service sshd -ErrorAction SilentlyContinue).Status
Write-Host ("sshd service = " + $(if($svc){$svc}else{'(khong tao duoc)'})) -ForegroundColor Green
$listen = netstat -ano | Select-String ':22\s' | Select-String LISTENING
if ($listen) { Write-Host '[OK] Dang nghe cong 22:' -ForegroundColor Green; $listen }
else {
  Write-Host '[!] Service chua nghe 22 — xem loi truc tiep:' -ForegroundColor Yellow
  & "$OSSH\sshd.exe" -ddd -p 22 2>&1 | Select-Object -First 12
}
Write-Host ('user = ' + $env:USERNAME)
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like '26.*' } | ForEach-Object { Write-Host ('IP Radmin = ' + $_.IPAddress) }
