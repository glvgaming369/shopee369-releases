# One-shot onboard CLIENT02 cua KH01 (license + config client + Node + mo app).
# TAM THOI tren repo -> XOA ngay sau khi chay (chua token host).
$ErrorActionPreference = 'Stop'
$p = Join-Path $env:LOCALAPPDATA 'Shopee369'
New-Item -ItemType Directory -Force $p | Out-Null

# 1) License (khoa theo may client02)
$b = 'ewogICJwYXlsb2FkIjogewogICAgImN1c3RvbWVyX2lkIjogIktIMDEtQ0xJRU5UMDIiLAogICAgIm1hY2hpbmVfaWQiOiAiZjFkOWQ4MGI4YTI1OGQ5NzA2NTJhYzNkNzg4OGUzNGUiLAogICAgInBsYW4iOiAic3RhbmRhcmQiLAogICAgImZlYXR1cmVzIjogWwogICAgICAiY3Jhd2xlciIsCiAgICAgICJ3ZWJhcHAiLAogICAgICAicG9zdGVyIgogICAgXSwKICAgICJpc3N1ZWRfYXQiOiAiMjAyNi0wNy0xNlQxNzoxOTo0Ny40MThaIiwKICAgICJleHBpcmVzX2F0IjogIjIwMjctMDctMTZUMTc6MTk6NDcuNDE4WiIKICB9LAogICJzaWduYXR1cmUiOiAidExhSkpQRzFxYkJZUmExUzQxVW1GTHVXUDFjRVgzZHIxZU5wTFpVWVJPNFdhNFVIYVFJTFB5WUFfblN6QmQ1RE9jdDFkR0FmUFVnVkdyMTZ0QjNsRHciCn0='
[IO.File]::WriteAllBytes((Join-Path $p 'license.json'), [Convert]::FromBase64String($b))
Write-Host '[OK] License client02' -ForegroundColor Green

# 2) Config CLIENT -> Funnel host KH01
$cfg = [ordered]@{
  dbMode           = 'client'
  sharedGatewayUrl = 'https://desktop-c88klt4.tailc714ad.ts.net'
  sharedAnonKey    = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIn0.Dzj729XpWf3MsqpMkWOw0JtXWB3JTBOjq-WvYf7L7Lk'
}
[IO.File]::WriteAllText((Join-Path $p 'config.json'), ($cfg | ConvertTo-Json))
Write-Host '[OK] Client config -> host KH01 (desktop-c88klt4)' -ForegroundColor Green

# 3) Node + mo app (client mode -> noi DB chung, khong chay Postgres rieng)
Write-Host '[*] Cai Node + mo app...' -ForegroundColor Cyan
irm https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/install-node.ps1 | iex
