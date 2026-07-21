# Start WSL, restart tier34, wait until /health responds (up to 90s)
$ErrorActionPreference = "Stop"
$maxWait = 90

Write-Host "==> Starting WSL Ubuntu..."
wsl -d Ubuntu -- true | Out-Null

Write-Host "==> Restarting tier34..."
wsl -d Ubuntu -- sudo systemctl restart tier34

Write-Host "==> Waiting for http://localhost:3001/health (up to ${maxWait}s)..."
$deadline = (Get-Date).AddSeconds($maxWait)
while ((Get-Date) -lt $deadline) {
  try {
    $r = Invoke-WebRequest -Uri "http://localhost:3001/health" -TimeoutSec 3 -UseBasicParsing
    if ($r.StatusCode -eq 200 -and $r.Content -match '"ok":true') {
      Write-Host "OK - tier34 is up"
      Write-Host $r.Content.Substring(0, [Math]::Min(200, $r.Content.Length))
      exit 0
    }
  } catch { }
  Start-Sleep -Seconds 3
  Write-Host "  still waiting..."
}

Write-Host "FAILED - tier34 did not respond in ${maxWait}s"
Write-Host "Run: wsl -d Ubuntu -- sudo journalctl -u tier34 -n 40 --no-pager"
exit 1
