#!/data/data/com.termux/files/usr/bin/bash
# ====================================================
# Jellyfin Server Auto-Installer for Termux on Android
# ----------------------------------------------------
# • Installs Ubuntu 24.04 LTS via proot-distro
# • Downloads portable ARM64 Jellyfin build
# • Links to Termux's ffmpeg
# • Creates easy start script:  start-jellyfin
# ====================================================

set -e

echo "[+] Updating Termux and installing tools..."
pkg update -y && pkg install -y proot-distro wget curl tar ffmpeg

#echo "[+] Installing Ubuntu 24.04 LTS..."
#proot-distro install ubuntu

echo "[+] Configuring Ubuntu environment..."
proot-distro login ubuntu -- bash -c '
set -e
apt update && apt install -y wget curl libicu74 libfontconfig1 ca-certificates

# --- Create Jellyfin directory ---
mkdir -p /opt/jellyfin
cd /opt/jellyfin

echo "[+] Downloading Jellyfin portable ARM64 build..."
wget https://repo.jellyfin.org/files/server/linux/latest-stable/arm64/jellyfin_10.10.6-arm64.tar.gz -O jellyfin.tar.gz

echo "[+] Extracting Jellyfin..."
tar xzf jellyfin.tar.gz && rm jellyfin.tar.gz
mkdir -p data cache config log

# --- Create start script ---
cat <<'"EOF"' > /usr/local/bin/start-jellyfin
#!/bin/bash
JELLYFINDIR="/opt/jellyfin"
FFMPEG_TERMUX="/data/data/com.termux/files/usr/bin/ffmpeg"

echo "[+] Starting Jellyfin..."
"$JELLYFINDIR/jellyfin/jellyfin" \
  -d "$JELLYFINDIR/data" \
  -C "$JELLYFINDIR/cache" \
  -c "$JELLYFINDIR/config" \
  -l "$JELLYFINDIR/log" \
  --ffmpeg "$FFMPEG_TERMUX" \
  >> "$JELLYFINDIR/log/jellyfin.out" 2>&1 &

echo "✅ Jellyfin started at http://localhost:8096"
EOF
chmod +x /usr/local/bin/start-jellyfin
'

echo
echo "✅ Installation complete!"
echo
echo "To start your Jellyfin server:"
echo "  proot-distro login ubuntu -- start-jellyfin"
echo
echo "Then open http://localhost:8096 in your browser or Jellyfin app."
echo
echo "Tip: use 'nohup proot-distro login ubuntu -- start-jellyfin &' to keep it running in background."

