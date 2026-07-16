# DEV-ONLY: ap migration 009 (affiliate link analysis) len DB embedded + test voi data that.
# Chay tren DEV SERVER (desktop-ted22dj) qua AnyDesk:
#   irm https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/apply-009-dev.ps1 | iex
$ErrorActionPreference = 'Stop'
$bin = "$env:LOCALAPPDATA\Programs\Shopee369\resources\pgsql\bin"
$psql = "$bin\psql.exe"
if (-not (Test-Path $psql)) { Write-Host '[X] Khong thay psql - app da cai chua?' -ForegroundColor Red; return }
$env:PGPASSWORD = (Get-Content "$env:LOCALAPPDATA\Shopee369\db-superuser.pw" -Raw).Trim()
$env:PGCLIENTENCODING = 'UTF8'
$sqlFile = "$env:TEMP\009_aff.sql"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$bust = [Guid]::NewGuid().ToString('N')  # cache-bust tránh CDN raw serve ban cu
(New-Object Net.WebClient).DownloadFile("https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/009_affiliate_link_analysis.sql?nocache=$bust", $sqlFile)

Write-Host '[*] Ap migration 009...' -ForegroundColor Cyan
& $psql -h 127.0.0.1 -p 54329 -U postgres -d appdb -v ON_ERROR_STOP=1 -f $sqlFile
Write-Host ''
Write-Host '=== DATA HIEN CO ===' -ForegroundColor Green
& $psql -h 127.0.0.1 -p 54329 -U postgres -d appdb -c "select (select count(*) from affiliate_orders) aff_orders, (select count(*) from affiliate_accounts) accounts, (select count(*) from products) crawler_products;"
Write-Host '=== PHAN LOAI LINK (enrich tu crawler that) ==='
& $psql -h 127.0.0.1 -p 54329 -U postgres -d appdb -c "select link_class, count(*) so_link, count(*) filter(where in_crawler) co_crawler, round(sum(money)) tien from aff_link_stats group by 1 order by 2 desc;"
Write-Host '=== TOP DANH SACH PHU ==='
& $psql -h 127.0.0.1 -p 54329 -U postgres -d appdb -c "select left(item_name,26) sp, round(money) tien, orders_earning don, n_accounts_earning acc, gap, distribution_priority uu_tien from aff_distribution_list(8);"
Write-Host '=== TOP SAN LINK MOI (rate_true tu crawler) ==='
& $psql -h 127.0.0.1 -p 54329 -U postgres -d appdb -c "select left(item_name,26) sp, orders_all don, rate_true rate, in_crawler, demand_score from aff_hunt_list(8);"
Write-Host ''
Write-Host '>>> XONG. Gui output nay cho ky thuat.' -ForegroundColor Yellow
