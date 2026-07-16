# Shopee369 — ghi config CLIENT (noi vao DB chung cua host qua Funnel).
# BAO MAT: token la bearer (khong khoa may) -> KHONG nhung vao repo. Truyen qua bien $T.
# Chay 1 dong (dat $T = token host truoc):
#   $T='<token-host>'; irm https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/setup-client.ps1 | iex
# (Tuy chon) tro host khac: dat them $H='https://<may>.<tailnet>.ts.net'. Mac dinh = host KH01.
$ErrorActionPreference = 'Stop'
$hostUrl = if ($H) { $H } else { 'https://desktop-c88klt4.tailc714ad.ts.net' }   # mac dinh: host KH01
if (-not $T) {
  Write-Host '[X] Thieu token. Chay:  $T=''<token-host>''; irm .../tools/setup-client.ps1 | iex' -ForegroundColor Red
  return
}
$p = Join-Path $env:LOCALAPPDATA 'Shopee369'
New-Item -ItemType Directory -Force $p | Out-Null
$cfg = [ordered]@{
  dbMode          = 'client'
  sharedGatewayUrl = $hostUrl
  sharedAnonKey    = $T
}
# UTF-8 KHONG BOM (Node JSON.parse loi neu co BOM)
[IO.File]::WriteAllText((Join-Path $p 'config.json'), ($cfg | ConvertTo-Json))
Write-Host ('[OK] CLIENT config -> ' + $hostUrl) -ForegroundColor Green
Write-Host '>>> Mo app Shopee369: no se noi vao DB chung cua host (khong chay Postgres rieng).'
