#!/bin/bash

echo "=== MACC installer (MAC Changer by MathewCrow) ==="

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo ./install.sh"
  exit 1
fi

apt update
apt install -y whiptail macchanger openssl policykit-1 desktop-file-utils

cp macc.sh /usr/local/bin/macc
chmod +x /usr/local/bin/macc

# Kopiowanie do globalnego folderu aplikacji
cp macc.desktop /usr/share/applications/macc.desktop
chmod 644 /usr/share/applications/macc.desktop

# KLUCZOWY KROK: Odświeżenie bazy, aby menu "zaskoczyło"
update-desktop-database /usr/share/applications/

echo
echo "✅ Installed successfully!"
echo "Run with:"
echo "  sudo macc"
echo "or search for 'MACC' in your application menu."
