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

# 2) Dam bao thu muc + FILE CONFIG (ban offline KHONG tao san sshd_config -> sshd thoat ngay)
$SSHDATA = "$env:ProgramData\ssh"
New-Item -ItemType Directory -Force $SSHDATA | Out-Null
if (-not (Test-Path "$SSHDATA\sshd_config")) { Copy-Item "$OSSH\sshd_config_default" "$SSHDATA\sshd_config" -Force }

# 3) Host keys + quyen
Write-Host '[*] Tao host keys...'
& "$OSSH\ssh-keygen.exe" -A | Out-Null
icacls "$SSHDATA\ssh_host_ed25519_key" /inheritance:r /grant 'SYSTEM:F' /grant 'Administrators:F' | Out-Null

# 4) Public key ky thuat (Shopee369)
$AK  = "$SSHDATA\administrators_authorized_keys"
$PUB = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFi1Ck1a2meO28JQUhOSadTQ739qwreXLDApdM2MqvO shopee369-deploy'
if (-not (Test-Path $AK) -or -not (Select-String $AK -Pattern 'shopee369-deploy' -Quiet)) { Add-Content $AK $PUB }
icacls $AK /inheritance:r /grant 'Administrators:F' /grant 'SYSTEM:F' | Out-Null

# 5) Firewall cong 22 (dung ca netsh + cmdlet cho chac)
& netsh advfirewall firewall delete rule name='OpenSSH-Server-In-TCP' | Out-Null
& netsh advfirewall firewall add rule name='OpenSSH-Server-In-TCP' dir=in action=allow protocol=TCP localport=22 profile=any | Out-Null
New-NetFirewallRule -DisplayName 'OpenSSH-Server-In-TCP' -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow -Profile Any -ErrorAction SilentlyContinue | Out-Null

# 6) Dang ky + bat SERVICE sshd (chay duoi SYSTEM, tu chay cung Windows)
& "$OSSH\install-sshd.ps1" | Out-Null
Set-Service sshd -StartupType Automatic
Start-Service sshd
Start-Sleep 2

# 7) Fallback neu SERVICE khong dang ky duoc (bi 'marked for deletion' -> can reboot):
#    tao Scheduled Task chay sshd duoi SYSTEM luc khoi dong (khong dung service).
if (-not (Get-Service sshd -ErrorAction SilentlyContinue) -or (Get-Service sshd).Status -ne 'Running') {
  Write-Host '[!] Service loi -> dung Scheduled Task (SYSTEM) lam fallback'
  schtasks /Create /TN 'Shopee369-SSHD' /TR "`"$OSSH\sshd.exe`"" /SC ONSTART /RU SYSTEM /RL HIGHEST /F | Out-Null
  schtasks /Run /TN 'Shopee369-SSHD' | Out-Null
  Start-Sleep 2
}

# 8) Ket qua
$svc = (Get-Service sshd -ErrorAction SilentlyContinue).Status
Write-Host ("sshd service = " + $(if($svc){$svc}else{'(khong co - dang chay qua Scheduled Task)'})) -ForegroundColor Green
$listen = netstat -ano | Select-String ':22\s' | Select-String LISTENING
if ($listen) { Write-Host '[OK] Dang nghe cong 22:' -ForegroundColor Green; $listen }
else { Write-Host '[!] CHUA nghe cong 22' -ForegroundColor Yellow }
Write-Host ('user = ' + $env:USERNAME)
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like '26.*' } | ForEach-Object { Write-Host ('IP Radmin = ' + $_.IPAddress) }
