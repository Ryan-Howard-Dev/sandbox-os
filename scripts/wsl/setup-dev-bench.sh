#!/usr/bin/env bash
# Sandbox OS dev bench — WSL2 Ubuntu/Debian
# Run: bash /mnt/c/Users/RH/Downloads/sandbox-os/scripts/wsl/setup-dev-bench.sh

set -euo pipefail

# Avoid installing user service as root (common when: wsl ... without default user)
if [[ "$(id -u)" -eq 0 ]] && [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  DEFAULT_USER=$(getent passwd | awk -F: '$3>=1000 && $3<65534 {print $1; exit}')
  if [[ -n "${DEFAULT_USER:-}" ]]; then
    echo "==> Re-running as user: $DEFAULT_USER (not root)"
    exec sudo -u "$DEFAULT_USER" env HOME="/home/$DEFAULT_USER" USER="$DEFAULT_USER" LOGNAME="$DEFAULT_USER" bash "$0" "$@"
  fi
fi

MUSIC_REPO="/mnt/c/Users/RH/Downloads/sovereign-music-console"
SERVICE_NAME="tier34"
NODE_MAJOR=22

echo "==> Sandbox WSL dev bench setup"

# --- Node 22 (tier34 needs node:sqlite) ---
if ! command -v node >/dev/null || [[ "$(node -p "process.versions.node.split('.')[0]")" -lt "$NODE_MAJOR" ]]; then
  echo "==> Installing Node.js ${NODE_MAJOR}.x"
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | sudo -E bash -
  sudo apt-get install -y nodejs
fi
echo "    Node $(node -v)"

# --- QEMU for ISO testing ---
echo "==> Installing QEMU"
sudo apt-get update -qq
sudo apt-get install -y qemu-system-x86 qemu-utils ovmf

# --- systemd user linger (service runs without login) ---
if command -v loginctl >/dev/null; then
  sudo loginctl enable-linger "$USER" 2>/dev/null || true
fi

# --- Remove duplicate user unit (causes EADDRINUSE on :3001) ---
systemctl --user disable "${SERVICE_NAME}" 2>/dev/null || true
systemctl --user stop "${SERVICE_NAME}" 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/${SERVICE_NAME}.service"
systemctl --user daemon-reload 2>/dev/null || true

# --- systemd service (system unit — more reliable than user unit on WSL) ---
sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null <<EOF
[Unit]
Description=Sandbox tier34 server (port 3001)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=${MUSIC_REPO}
Environment=NODE_ENV=production
ExecStartPre=-/usr/bin/fuser -k 3001/tcp
ExecStart=$(command -v npm) run start:tier34
Restart=on-failure
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable "${SERVICE_NAME}.service"
sudo systemctl restart "${SERVICE_NAME}.service"

sleep 25
if curl -sf "http://127.0.0.1:3001/health" >/dev/null 2>&1; then
  echo "==> tier34 healthy: http://localhost:3001/health"
else
  echo "==> tier34 not ready yet — slow start on /mnt/c (wait 30s, then curl /health)"
  sudo systemctl status "${SERVICE_NAME}" --no-pager -l || true
  sudo journalctl -u "${SERVICE_NAME}" -n 30 --no-pager || true
fi

echo ""
echo "Done. From Windows: http://localhost:3001/health"
echo "  sudo systemctl status ${SERVICE_NAME}"
echo "  sudo systemctl restart ${SERVICE_NAME}"
echo "  qemu-system-x86_64 --version"
