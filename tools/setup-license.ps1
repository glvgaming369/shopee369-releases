# Shopee369 — nap license cho HOST-CHINH (DESKTOP-TED22DJ). Chay 1 dong:
#   irm https://raw.githubusercontent.com/glvgaming369/shopee369-releases/main/tools/setup-license.ps1 | iex
$b = 'ewogICJwYXlsb2FkIjogewogICAgImN1c3RvbWVyX2lkIjogIkhPU1QtQ0hJTkgiLAogICAgIm1hY2hpbmVfaWQiOiAiYTA3NjgxZDZlM2Y2ZWFlYWJmMTljZGY1ODJjOGVhOTYiLAogICAgInBsYW4iOiAic3RhbmRhcmQiLAogICAgImZlYXR1cmVzIjogWwogICAgICAiY3Jhd2xlciIsCiAgICAgICJ3ZWJhcHAiLAogICAgICAicG9zdGVyIgogICAgXSwKICAgICJpc3N1ZWRfYXQiOiAiMjAyNi0wNy0xNVQyMzoyODoxOC41NzRaIiwKICAgICJleHBpcmVzX2F0IjogIjIwMzYtMDctMTJUMjM6Mjg6MTguNTc0WiIKICB9LAogICJzaWduYXR1cmUiOiAiSlRmU2xVWGVESGw5SGV0LWpFTlBtcUFVblZ6UlNBeVNkWW1fM241NWlkdThXa2Etby0yeUpIbmQ5eUVoR0dLSGNvN2dpV3dFa0hHNmxZbDVINXNxQ0EiCn0='
$p = Join-Path $env:LOCALAPPDATA 'Shopee369'
New-Item -ItemType Directory -Force $p | Out-Null
[IO.File]::WriteAllBytes((Join-Path $p 'license.json'), [Convert]::FromBase64String($b))
Write-Host 'LICENSE OK — gio mo app Shopee369 (double-click), cho 3 tab hien ra.' -ForegroundColor Green
