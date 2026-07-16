# Shopee369 — tro Tailscale Funnel sang gateway app (54331). Chay 1 dong:
#   irm https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/tailscale-funnel-54331.ps1 | iex
$t = 'C:\Program Files\Tailscale\tailscale.exe'
if (-not (Test-Path $t)) { Write-Host '[X] Chua cai Tailscale' -ForegroundColor Red; return }
Write-Host '=== Tro Funnel -> gateway app 54331 ===' -ForegroundColor Cyan
Write-Host '[*] Xoa cau hinh serve/funnel cu (dang tro 8000)...'
& $t serve reset 2>&1
Write-Host '[*] Bat Funnel moi -> http://127.0.0.1:54331 ...'
& $t funnel --bg 54331 2>&1
Start-Sleep 2
Write-Host '--- funnel status ---' -ForegroundColor Green
$stat = & $t funnel status 2>&1 | Out-String
Write-Host $stat
$m = [regex]::Match($stat, 'https://[\w.-]+\.ts\.net')
$publicUrl = if ($m.Success) { $m.Value } else { '(xem dong funnel status o tren)' }
Write-Host ('>>> URL public cho userscript (may nay): ' + $publicUrl) -ForegroundColor Yellow
