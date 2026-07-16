# Shopee369 — cai Node.js (app can npm de build webapp lan dau) + mo lai app. Chay 1 dong:
#   irm https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/install-node.ps1 | iex
$ErrorActionPreference = 'Stop'
Write-Host '=== Cai Node.js cho Shopee369 ===' -ForegroundColor Cyan
$nodeDir = 'C:\Program Files\nodejs'
if (-not (Test-Path "$nodeDir\npm.cmd")) {
  $msi = "$env:TEMP\node-lts.msi"
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Write-Host '[*] Tai Node.js LTS (~30MB)...'
  (New-Object Net.WebClient).DownloadFile('https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi', $msi)
  Write-Host '[*] Cai im lang...'
  Start-Process msiexec -ArgumentList "/i `"$msi`" /qn /norestart" -Wait
} else { Write-Host '[i] Node da co san.' }

# Them Node vao PATH cua phien nay de app spawn npm duoc
if ($env:PATH -notlike "*$nodeDir*") { $env:PATH += ";$nodeDir" }
Write-Host ('node = ' + (& "$nodeDir\node.exe" -v))
Write-Host ('npm  = ' + (& "$nodeDir\npm.cmd" -v))

# Tat app cu (neu con) roi mo lai voi PATH co Node -> first-run build webapp se chay
Get-Process Shopee369 -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 2
$app = "$env:LOCALAPPDATA\Programs\Shopee369\Shopee369.exe"
Write-Host '[*] Mo lai app (first-run se build webapp ~1-2 phut)...' -ForegroundColor Green
Start-Process $app
Write-Host '>>> Cho 1-2 phut, cua so 3 tab se hien. Neu can kiem tra: chay lai check-app.ps1' -ForegroundColor Yellow
