# DEV-ONLY: mo PG embedded (127.0.0.1:54329) ra Radmin qua portproxy 0.0.0.0:5433 + in password.
# Chay PowerShell ADMIN tren DEV SERVER (desktop-ted22dj) qua AnyDesk:
#   irm "https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/dev-pg-portproxy.ps1?n=$(Get-Random)" | iex
# GO BO khi xong: netsh interface portproxy delete v4tov4 listenport=5433 listenaddress=0.0.0.0
$ErrorActionPreference = 'SilentlyContinue'
$LISTEN = 5433
Write-Host '=== Mo portproxy 0.0.0.0:5433 -> 127.0.0.1:54329 ===' -ForegroundColor Cyan
netsh interface portproxy delete v4tov4 listenport=$LISTEN listenaddress=0.0.0.0 | Out-Null
netsh interface portproxy add v4tov4 listenport=$LISTEN listenaddress=0.0.0.0 connectport=54329 connectaddress=127.0.0.1
netsh advfirewall firewall delete rule name='dev-pg-5433' | Out-Null
netsh advfirewall firewall add rule name='dev-pg-5433' dir=in action=allow protocol=TCP localport=$LISTEN profile=any | Out-Null
New-NetFirewallRule -DisplayName 'dev-pg-5433' -Direction Inbound -Protocol TCP -LocalPort $LISTEN -Action Allow -Profile Any -ErrorAction SilentlyContinue | Out-Null

Write-Host '--- portproxy hien tai ---'
netsh interface portproxy show v4tov4
$listen22 = netstat -ano | Select-String ":$LISTEN\s" | Select-String LISTENING
Write-Host ('--- nghe cong 5433: ' + [bool]$listen22 + ' ---')

$pwFile = "$env:LOCALAPPDATA\Shopee369\db-superuser.pw"
if (Test-Path $pwFile) {
  $pw = (Get-Content $pwFile -Raw).Trim()
  Write-Host ''
  Write-Host ('>>> PG PASSWORD (gui cho ky thuat): ' + $pw) -ForegroundColor Yellow
  Write-Host '>>> Ket noi: host=26.75.253.219 port=5433 db=appdb user=postgres'
} else { Write-Host '[X] Khong thay db-superuser.pw - app da chay lan dau chua?' -ForegroundColor Red }
Write-Host '>>> Nho GO BO sau: netsh interface portproxy delete v4tov4 listenport=5433 listenaddress=0.0.0.0'
