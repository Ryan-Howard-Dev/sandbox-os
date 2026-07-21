# Quick tier34 check from Windows
# Usage: .\scripts\wsl\tier34-status.ps1

Write-Host "==> WSL Ubuntu"
$wsl = wsl -d Ubuntu -- echo ok 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Host "WSL not running. Start: wsl -d Ubuntu"
  exit 1
}

Write-Host "==> systemd tier34 (system)"
wsl -d Ubuntu -- sudo systemctl is-active tier34 2>&1

Write-Host "==> port 3001 in WSL"
wsl -d Ubuntu -- bash -lc "ss -tln | grep 3001 || echo NOT LISTENING"

Write-Host "==> health from Windows"
try {
  $r = Invoke-WebRequest -Uri "http://localhost:3001/health" -TimeoutSec 5 -UseBasicParsing
  Write-Host "OK $($r.StatusCode): $($r.Content.Substring(0, [Math]::Min(120, $r.Content.Length)))..."
} catch {
  Write-Host "FAILED: $($_.Exception.Message)"
  Write-Host ""
  Write-Host "Likely: WSL just booted - tier34 needs 20-40s on /mnt/c repo."
  Write-Host "Fix: wsl -d Ubuntu -- sudo systemctl restart tier34"
  Write-Host "Then wait 30s and re-run this script."
  exit 1
}
