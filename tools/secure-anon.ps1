# Shopee369 — KHOA role anon (token-only) cho gateway cong khai (Funnel). Chay 1 dong:
#   irm https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/secure-anon.ps1 | iex
# An toan: webapp + crawler deu dung service token, KHONG dung anon -> khong vo gi.
$ErrorActionPreference = 'Stop'
Write-Host '=== Khoa anon (token-only) ===' -ForegroundColor Cyan
$psql = "$env:LOCALAPPDATA\Programs\Shopee369\resources\pgsql\bin\psql.exe"
if (-not (Test-Path $psql)) { Write-Host '[X] Khong thay psql — app da cai chua?' -ForegroundColor Red; return }
$env:PGPASSWORD = (Get-Content "$env:LOCALAPPDATA\Shopee369\db-superuser.pw" -Raw).Trim()
$sql = @"
DELETE FROM public.products WHERE itemid = '_sectest_';
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon;
REVOKE ALL ON ALL ROUTINES IN SCHEMA public FROM anon;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM anon;
REVOKE USAGE ON SCHEMA public FROM anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON ROUTINES FROM anon;
NOTIFY pgrst, 'reload schema';
"@
& $psql -h 127.0.0.1 -p 54329 -U postgres -d appdb -v ON_ERROR_STOP=1 -c $sql
Write-Host '[OK] Da khoa anon. Moi request qua gateway BAT BUOC co Bearer token.' -ForegroundColor Green
