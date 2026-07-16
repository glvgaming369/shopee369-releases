# Shopee369 — kiem tra Tailscale tren host. Chay 1 dong:
#   irm https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/check-tailscale.ps1 | iex
Write-Host '=== Kiem tra Tailscale ===' -ForegroundColor Cyan
$t = 'C:\Program Files\Tailscale\tailscale.exe'
if (Test-Path $t) {
  Write-Host '[OK] Tailscale DA CAI' -ForegroundColor Green
  Write-Host '--- version ---'; & $t version
  Write-Host '--- status ---'; & $t status 2>&1
  Write-Host '--- funnel status ---'; & $t funnel status 2>&1
} else {
  Write-Host '[!] Tailscale CHUA CAI tren may nay.' -ForegroundColor Yellow
  Write-Host '    (Se soan script cai + login + bat Funnel.)'
}
