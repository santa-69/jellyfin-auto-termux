#!/data/data/com.termux/files/usr/bin/bash
# ===========================================
# Jellyfin Server installer for Termux + Proot Ubuntu
# Author: Andrew Dore
# Platform: Android (Termux)
# ===========================================

set -e

echo "== Updating Termux and installing prerequisites =="
pkg update -y && pkg upgrade -y
pkg install -y proot-distro ffmpeg wget curl gnupg nano sudo

echo "== Installing Ubuntu rootfs via proot-distro =="
proot-distro install ubuntu || true

echo "== Performing first setup in Ubuntu environment =="
proot-distro login ubuntu -- bash -c "
  apt update && apt upgrade -y
  apt install -y wget sudo curl gnupg ffmpeg nano

  echo '== Applying .NET memory fix for Jellyfin =='
  cat > /etc/profile.d/02-dotnet-fix.sh <<'EOF'
export DOTNET_GCHeapHardLimit=1C0000000
EOF
  chmod +x /etc/profile.d/02-dotnet-fix.sh
"

echo "== Re-entering Ubuntu to install Jellyfin =="
proot-distro login ubuntu -- bash -c "
  cd /root || cd ~
  echo '== Downloading Jellyfin server package =='
  wget -O jellyfin.deb https://repo.jellyfin.org/files/server/ubuntu/latest-stable/arm64/jellyfin-server_10.11.2+ubu2404_arm64.deb

  echo '== Installing Jellyfin server =='
  dpkg -i jellyfin.deb || apt install -f -y

  echo '== Launching Jellyfin in background =='
  nohup jellyfin > jellyfin.log 2>&1 &
  echo 'Jellyfin server started (check jellyfin.log for details)'
"

echo "== Installation complete! =="
echo "Access Jellyfin from your Android browser at: http://localhost:8096"

