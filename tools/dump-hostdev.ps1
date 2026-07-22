# Chay tren MAY HOST THAT (qua AnyDesk) -- dump products+machines tu embedded Postgres
# (54329) ra 1 file, de chuyen sang may dev qua AnyDesk file transfer.
$ErrorActionPreference = 'Stop'
Write-Host '=== Shopee369 DUMP DATA CHO HOST-DEV ===' -ForegroundColor Cyan
$bin = "$env:LOCALAPPDATA\Programs\Shopee369\resources\pgsql\bin"
$pgdump = "$bin\pg_dump.exe"
if (-not (Test-Path $pgdump)) { throw "Khong thay pg_dump o $bin -- app da cai chua?" }
$pw = (Get-Content "$env:LOCALAPPDATA\Shopee369\db-superuser.pw" -Raw).Trim()
$env:PGPASSWORD = $pw
$dump = "$env:USERPROFILE\Desktop\hostdev_seed.dump"
& $pgdump -h 127.0.0.1 -p 54329 -U postgres -d appdb -Fc --data-only --no-owner -t products -t machines -f $dump
Write-Host ('[OK] Dump xong: ' + $dump + ' (' + [math]::Round((Get-Item $dump).Length/1MB,1) + 'MB)') -ForegroundColor Green
Write-Host '>>> Keo file nay qua AnyDesk sang may dev.' -ForegroundColor Yellow
