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

# 2) Go service cu (neu hong) roi cai lai sach
if (Get-Service sshd -ErrorAction SilentlyContinue) { Stop-Service sshd -Force; & sc.exe delete sshd | Out-Null; Start-Sleep 1 }
Write-Host '[*] Cai dich vu sshd...'
& "$OSSH\install-sshd.ps1" | Out-Null

# 3) Host keys (bat buoc — ban offline khong tu tao)
Write-Host '[*] Tao host keys...'
& "$OSSH\ssh-keygen.exe" -A | Out-Null
icacls "$env:ProgramData\ssh\ssh_host_ed25519_key" /inheritance:r /grant 'SYSTEM:F' /grant 'Administrators:F' | Out-Null

# 4) Firewall cong 22
New-NetFirewallRule -DisplayName 'OpenSSH-SSH-22' -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow -Profile Any -ErrorAction SilentlyContinue | Out-Null

# 5) Public key ky thuat (Shopee369)
$AK  = "$env:ProgramData\ssh\administrators_authorized_keys"
$PUB = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFi1Ck1a2meO28JQUhOSadTQ739qwreXLDApdM2MqvO shopee369-deploy'
if (-not (Test-Path $AK) -or -not (Select-String $AK -Pattern 'shopee369-deploy' -Quiet)) { Add-Content $AK $PUB }
icacls $AK /inheritance:r /grant 'Administrators:F' /grant 'SYSTEM:F' | Out-Null

# 6) Auto-start + khoi dong
Set-Service sshd -StartupType Automatic
Start-Service sshd
Start-Sleep 2

# 7) Ket qua
Write-Host ('sshd = ' + (Get-Service sshd).Status) -ForegroundColor Green
$listen = netstat -ano | Select-String ':22\s' | Select-String LISTENING
if ($listen) { Write-Host '[OK] Dang nghe cong 22:' -ForegroundColor Green; $listen }
else { Write-Host '[!] CHUA nghe cong 22 — chay de xem loi:  & "$env:ProgramFiles\OpenSSH-Win64\sshd.exe" -ddd -p 22' -ForegroundColor Yellow }
Write-Host ('user = ' + $env:USERNAME)
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like '26.*' } | ForEach-Object { Write-Host ('IP Radmin = ' + $_.IPAddress) }
