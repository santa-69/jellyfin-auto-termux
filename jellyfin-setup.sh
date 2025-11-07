#!/data/data/com.termux/files/usr/bin/bash
# ====================================================
# Jellyfin Server installer for Termux (Ubuntu proot)
# Works on ARM64 Android TV boxes
# ====================================================

echo "[+] Updating Termux packages..."
pkg update -y && pkg install -y proot-distro wget curl ffmpeg

echo "[+] Installing Ubuntu 24.04 (LTS)..."
proot-distro install ubuntu
echo "[+] Entering Ubuntu..."
proot-distro login ubuntu -- bash -c '
set -e

echo "[+] Updating Ubuntu..."
apt update && apt upgrade -y
apt install -y curl gnupg lsb-release ca-certificates apt-transport-https

echo "[+] Adding Jellyfin repository..."
curl -fsSL https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key \
  | gpg --dearmor -o /usr/share/keyrings/jellyfin.gpg

echo "deb [signed-by=/usr/share/keyrings/jellyfin.gpg arch=arm64] https://repo.jellyfin.org/ubuntu noble main" \
  > /etc/apt/sources.list.d/jellyfin.list

echo "[+] Installing Jellyfin..."
apt update && apt install -y jellyfin

echo "[+] Creating start script..."
cat <<'"EOF"' > /usr/local/bin/start-jellyfin
#!/bin/bash
/usr/bin/jellyfin \
  --datadir /var/lib/jellyfin \
  --configdir /etc/jellyfin \
  --cachedir /var/cache/jellyfin \
  > /root/jellyfin.log 2>&1 &
echo "Jellyfin started at http://localhost:8096"
EOF
chmod +x /usr/local/bin/start-jellyfin

echo "[+] Done! Run 'start-jellyfin' to start Jellyfin."
'

echo
echo "✅ Installation complete."
echo "To start your server:"
echo "  proot-distro login ubuntu -- start-jellyfin"
echo
echo "Then open http://localhost:8096 in your browser."

