# Shopee369 — cai Node.js (app can npm de build webapp lan dau) + mo lai app. Chay 1 dong:
#   irm https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/install-node.ps1 | iex
$ErrorActionPreference = 'Stop'
Write-Host '=== Cai Node.js cho Shopee369 ===' -ForegroundColor Cyan
$nodeDir = 'C:\Program Files\nodejs'
# Kiem tra phien ban Node trong PATH (Next.js can >= 18). Node cu (vd 14) -> nang cap.
$cur = $null
try { $cur = (& node -v) 2>$null } catch {}
$okVer = $false
if ($cur) { try { if ([int]($cur.TrimStart('v').Split('.')[0]) -ge 18) { $okVer = $true } } catch {} }
if ($okVer) {
  Write-Host ("[i] Node $cur da du (>=18).")
} else {
  if ($cur) { Write-Host ("[!] Node $cur QUA CU (<18) -> cai Node 20 LTS.") -ForegroundColor Yellow }
  else { Write-Host '[*] Chua co Node -> cai Node 20 LTS...' }
  $msi = "$env:TEMP\node-lts.msi"
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  (New-Object Net.WebClient).DownloadFile('https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi', $msi)
  Start-Process msiexec -ArgumentList "/i `"$msi`" /qn /norestart" -Wait
}

# Dam bao Node 20 (C:\Program Files\nodejs) DUNG DAU PATH phien nay (dan truoc Node cu neu co)
$env:PATH = "$nodeDir;" + ($env:PATH -replace [regex]::Escape("$nodeDir;"), '')
Write-Host ('node = ' + (& "$nodeDir\node.exe" -v))
Write-Host ('npm  = ' + (& "$nodeDir\npm.cmd" -v))

# Tat app cu (neu con) roi mo lai voi PATH co Node -> first-run build webapp se chay
Get-Process Shopee369 -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 2
# Xoa .next build do (co the do Node cu build that bai) -> build lai sach
$dotNext = "$env:LOCALAPPDATA\Programs\Shopee369\resources\webapp\.next"
if (Test-Path $dotNext) { Remove-Item -Recurse -Force $dotNext -ErrorAction SilentlyContinue }
$app = "$env:LOCALAPPDATA\Programs\Shopee369\Shopee369.exe"
Write-Host '[*] Mo lai app (first-run se build webapp ~1-2 phut)...' -ForegroundColor Green
Start-Process $app
Write-Host '>>> Cho 1-2 phut, cua so 3 tab se hien. Neu can kiem tra: chay lai check-app.ps1' -ForegroundColor Yellow
