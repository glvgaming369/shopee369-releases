# Shopee369 — chan doan app khong mo. Chay 1 dong:
#   irm https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/check-app.ps1 | iex
Write-Host '=== Shopee369 chan doan ===' -ForegroundColor Cyan
$dir = "$env:LOCALAPPDATA\Programs\Shopee369"
$app = "$dir\Shopee369.exe"
$ud  = "$env:LOCALAPPDATA\Shopee369"
Write-Host ('exe ton tai      : ' + (Test-Path $app))
Write-Host ('license.json     : ' + (Test-Path "$ud\license.json"))
Write-Host ('pgdata (da first-run?): ' + (Test-Path "$ud\pgdata"))

# license hop le?
if (Test-Path $app) {
  $env:ELECTRON_RUN_AS_NODE = '1'
  try { $lic = & $app -e "console.log(JSON.stringify(require(process.argv[1]).check()))" "$dir\resources\app.asar\src\license.js" 2>&1 } catch { $lic = "ERR $_" }
  $env:ELECTRON_RUN_AS_NODE = ''
  Write-Host ('license.check    : ' + $lic)
}

# Defender co chan/xoa khong?
Write-Host '--- Defender threats (5 gan nhat) ---'
$th = Get-MpThreatDetection -ErrorAction SilentlyContinue | Sort-Object InitialDetectionTime | Select-Object -Last 5
if ($th) { $th | ForEach-Object { Write-Host ('  ' + $_.InitialDetectionTime + '  ' + ($_.Resources -join ',')) } } else { Write-Host '  (khong co)' }

# log first-run
if (Test-Path "$ud\logs") {
  Get-ChildItem "$ud\logs" -File | Sort-Object LastWriteTime | Select-Object -Last 2 | ForEach-Object {
    Write-Host ('--- log: ' + $_.Name + ' ---'); Get-Content $_.FullName -Tail 15
  }
} else { Write-Host '(chua co thu muc logs — app chua chay duoc lan nao)' }

# Thu chay app, bat stdout/stderr trong 10s
Write-Host '--- thu chay app 10s (bat log) ---'
if (Test-Path $app) {
  $env:ELECTRON_ENABLE_LOGGING = '1'
  $out = "$env:TEMP\s369out.txt"; $err = "$env:TEMP\s369err.txt"
  $p = Start-Process $app -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
  Start-Sleep 10
  if ($p.HasExited) { Write-Host ('  -> app DA THOAT, exit code = ' + $p.ExitCode) -ForegroundColor Yellow }
  else { Write-Host '  -> app CON CHAY sau 10s (co the dang build)' -ForegroundColor Green }
  Write-Host '--- stdout (cuoi) ---'; Get-Content $out -Tail 20 -ErrorAction SilentlyContinue
  Write-Host '--- stderr (cuoi) ---'; Get-Content $err -Tail 20 -ErrorAction SilentlyContinue
}
