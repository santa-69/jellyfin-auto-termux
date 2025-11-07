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

echo "== Installing Jellyfin from official 22.04 (Jammy) repo =="
proot-distro login ubuntu -- bash -c "
  apt update && apt upgrade -y
  apt install -y wget curl gnupg ffmpeg apt-transport-https
  wget -O- https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | gpg --dearmor -o /usr/share/keyrings/jellyfin.gpg
  echo 'deb [signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/ubuntu jammy main' > /etc/apt/sources.list.d/jellyfin.list
  apt update
  apt install -y jellyfin
  nohup jellyfin > jellyfin.log 2>&1 &
"


