# Shopee369 — nap data cu (appdb cong 5432) sang DB embedded (appdb cong 54329). Chay 1 dong:
#   irm https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/import-data.ps1 | iex
$ErrorActionPreference = 'Stop'
Write-Host '=== Shopee369 NAP DATA CU -> EMBEDDED ===' -ForegroundColor Cyan
$bin = "$env:LOCALAPPDATA\Programs\Shopee369\resources\pgsql\bin"
$pgdump = "$bin\pg_dump.exe"; $pgrestore = "$bin\pg_restore.exe"; $psql = "$bin\psql.exe"
if (-not (Test-Path $pgdump)) { throw "Khong thay pg_dump o $bin — app da cai chua?" }
$newpw = (Get-Content "$env:LOCALAPPDATA\Shopee369\db-superuser.pw" -Raw).Trim()
$tables = 'products','keywords','affiliate_orders','blacklist','affiliate_accounts','machines'
$dump = "$env:TEMP\appdb_data.dump"

# 1) Dump data-only tu Postgres CU (127.0.0.1:5432, user postgres)
Write-Host '[*] Dump data tu Postgres cu (5432)...'
$env:PGPASSWORD = 'namlo@123'
$targs = @(); foreach ($t in $tables) { $targs += '-t'; $targs += $t }
& $pgdump -h 127.0.0.1 -p 5432 -U postgres -d appdb -Fc --data-only --no-owner @targs -f $dump
Write-Host ('[*] Dump xong: ' + [math]::Round((Get-Item $dump).Length/1MB,1) + 'MB')

# 2) Don bang dich (xoa demo neu co) + restore vao EMBEDDED (54329)
$env:PGPASSWORD = $newpw
Write-Host '[*] Don bang dich embedded (54329)...'
& $psql -h 127.0.0.1 -p 54329 -U postgres -d appdb -v ON_ERROR_STOP=1 -c "TRUNCATE products,keywords,affiliate_orders,blacklist,affiliate_accounts,machines RESTART IDENTITY CASCADE;"
Write-Host '[*] Nap data (disable-triggers)...'
& $pgrestore -h 127.0.0.1 -p 54329 -U postgres -d appdb --data-only --disable-triggers --no-owner $dump 2>&1 | Select-Object -Last 5

# 3) Kiem dem
Write-Host '--- SO DONG SAU NAP (embedded appdb) ---' -ForegroundColor Green
foreach ($t in $tables) {
  $c = & $psql -h 127.0.0.1 -p 54329 -U postgres -d appdb -tAc "select count(*) from $t"
  Write-Host ("  {0,-20} {1}" -f $t, ($c -join ''))
}
Write-Host 'DONE — mo tab Webapp/Bao cao trong app de xem data.' -ForegroundColor Green
