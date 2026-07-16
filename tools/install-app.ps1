# Shopee369 — tai + cai app Electron (im lang) + in machine-id. Chay PowerShell Admin, hoac 1 dong:
#   irm https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/install-app.ps1 | iex
$ErrorActionPreference = 'Stop'
Write-Host '=== Shopee369 cai app ===' -ForegroundColor Cyan
$exe = "$env:TEMP\Shopee369-Setup.exe"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Luon lay BAN MOI NHAT tu GitHub Releases (tranh hardcode phien ban cu)
$rel = Invoke-RestMethod -UseBasicParsing -Headers @{ 'User-Agent' = 'shopee369' } 'https://api.github.com/repos/glvgaming369/shopee369-releases/releases/latest'
$dl = ($rel.assets | Where-Object { $_.name -like '*.exe' } | Select-Object -First 1).browser_download_url
Write-Host ('[*] Tai installer ' + $rel.tag_name + ' ~531MB (cho vai phut)...')
(New-Object Net.WebClient).DownloadFile($dl, $exe)
Write-Host ('[*] Tai xong ' + [math]::Round((Get-Item $exe).Length/1MB,1) + 'MB. Dang cai im lang...')
Start-Process $exe -ArgumentList '/S' -Wait
Start-Sleep 6
$app = "$env:LOCALAPPDATA\Programs\Shopee369\Shopee369.exe"
$n = 0; while (-not (Test-Path $app) -and $n -lt 12) { Start-Sleep 5; $n++ }
if (Test-Path $app) {
  Write-Host ('[OK] Da cai: ' + $app) -ForegroundColor Green
  $asar = "$env:LOCALAPPDATA\Programs\Shopee369\resources\app.asar\src\machine-id.js"
  $env:ELECTRON_RUN_AS_NODE = '1'
  $mid = & $app -e "console.log(require(process.argv[1]).machineId())" $asar
  $env:ELECTRON_RUN_AS_NODE = ''
  Write-Host ''
  Write-Host ('>>> MACHINE_ID = ' + $mid) -ForegroundColor Yellow
  Write-Host '>>> Gui dong MACHINE_ID nay cho ky thuat de phat license.'
} else {
  Write-Host '[X] Khong thay app sau khi cai — bao ky thuat.' -ForegroundColor Red
}
