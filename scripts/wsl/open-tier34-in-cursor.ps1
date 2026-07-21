# Open tier34 /health in Cursor's integrated Simple Browser (not external Chrome)
$url = "http://localhost:3001/health"
$encoded = [uri]::EscapeDataString($url)

try {
  $r = Invoke-WebRequest -Uri $url -TimeoutSec 3 -UseBasicParsing
  if ($r.StatusCode -ne 200) { throw "tier34 returned $($r.StatusCode)" }
} catch {
  Write-Host "tier34 not up — starting on Windows..."
  Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$env:USERPROFILE\Downloads\sovereign-music-console'; npm run start:tier34"
  Write-Host "Wait ~20s, then run this script again."
  exit 1
}

cursor --open-url "vscode://vscode.simple-browser/show?url=$encoded"
Write-Host "Opened in Cursor Simple Browser: $url"
