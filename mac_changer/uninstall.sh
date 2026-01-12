#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo ./uninstall.sh"
  exit 1
fi

rm -f /usr/local/bin/macc
rm -f /usr/share/applications/macc.desktop
rm -f /etc/macc.conf

echo "✅ MACC fully removed"
