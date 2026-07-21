# Optional: install Debian alongside Ubuntu in WSL2
# Run in PowerShell (Admin may be required): .\install-debian-wsl.ps1

$distros = wsl -l -q 2>$null
if ($distros -match "Debian") {
  Write-Host "Debian WSL already installed."
  wsl -d Debian -- bash -lc "cat /etc/os-release | head -3"
  exit 0
}

Write-Host "Installing Debian via wsl --install..."
wsl --install -d Debian --no-launch
Write-Host "Debian installed. First run: wsl -d Debian"
Write-Host "Then run setup-dev-bench.sh inside Debian."
