# DEV: nhan dien AV + whitelist sshd (Defender) + bat lai sshd. Chay PowerShell ADMIN qua AnyDesk:
#   irm "https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/fix-av-ssh.ps1?n=$(Get-Random)" | iex
$ErrorActionPreference = 'SilentlyContinue'
Write-Host '=== 1) AV dang cai (SecurityCenter2) ===' -ForegroundColor Cyan
Get-CimInstance -Namespace root/SecurityCenter2 -Class AntiVirusProduct | ForEach-Object { Write-Host ('   AV: ' + $_.displayName) }
$avp = Get-Process | Where-Object { $_.ProcessName -match '360|zhudong|bkav|kaspersky|avp|avast|avgui|avguard|mcafee|norton|ekrn|nod32|qqpcmgr|qqpctray|huorong|hipstray|sysdiag' } | Select-Object -Expand ProcessName -Unique
if ($avp) { Write-Host ('   [!] Process AV ben thu 3: ' + ($avp -join ', ')) -ForegroundColor Yellow } else { Write-Host '   Khong thay AV ben thu 3 dang chay -> nhieu kha nang chi Windows Defender' -ForegroundColor Green }

Write-Host '=== 2) Them exclusion cho OpenSSH vao Windows Defender ===' -ForegroundColor Cyan
$ossh = "$env:ProgramFiles\OpenSSH-Win64"
Add-MpPreference -ExclusionPath $ossh
Add-MpPreference -ExclusionProcess "$ossh\sshd.exe"
Add-MpPreference -ExclusionProcess 'sshd.exe'
Add-MpPreference -ExclusionProcess 'ssh-agent.exe'
$ex = (Get-MpPreference).ExclusionProcess
Write-Host ('   ExclusionProcess: ' + ($ex -join ', '))
Write-Host ('   ExclusionPath co OpenSSH: ' + [bool]((Get-MpPreference).ExclusionPath -contains $ossh))

Write-Host '=== 3) Bat lai sshd ===' -ForegroundColor Cyan
Get-Process sshd -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$svc = Get-Service sshd -ErrorAction SilentlyContinue
if ($svc) { Set-Service sshd -StartupType Automatic; Start-Service sshd; Start-Sleep 2; Write-Host ('   sshd service = ' + (Get-Service sshd).Status) }
else { Write-Host '   [!] Chua co service sshd -> chay enable-ssh.ps1 truoc, roi chay lai file nay.' -ForegroundColor Yellow }

$listen = netstat -ano | Select-String ':22\s' | Select-String LISTENING
if ($listen) { Write-Host '   [OK] Dang nghe cong 22:' -ForegroundColor Green; $listen } else { Write-Host '   [!] Chua nghe cong 22' -ForegroundColor Yellow }
Write-Host '=== IP ==='; Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like '26.*' } | ForEach-Object { Write-Host ('   Radmin: ' + $_.IPAddress) }
Write-Host '>>> XONG. De sshd chay ~1 phut roi bao ky thuat test SSH (xem co bi giet lai khong).'
