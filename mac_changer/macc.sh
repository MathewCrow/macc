#!/bin/bash

APP_NAME="MAC Changer by MathewCrow"
CONFIG_FILE="/etc/macc.conf"

# =========================
# Root check
# =========================
if [[ $EUID -ne 0 ]]; then
  echo "❌ Run as root (sudo)"
  exit 1
fi

# =========================
# Help
# =========================
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "$APP_NAME"
  echo
  echo "Usage:"
  echo "  sudo macc"
  echo
  echo "Features:"
  echo "  - Interface selection"
  echo "  - Random MAC"
  echo "  - Vendor-based MAC"
  echo "  - Language memory (PL / EN)"
  echo "  - Kali menu launcher"
  exit 0
fi

# =========================
# Language config
# =========================
save_lang() {
  echo "LANG=$1" > "$CONFIG_FILE"
}

load_lang() {
  [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
}

load_lang

if [[ -z "$LANG" ]]; then
  LANG=$(whiptail --title "$APP_NAME" \
  --menu "Choose language / Wybierz język" 12 50 2 \
  "PL" "Polski" \
  "EN" "English" \
  3>&1 1>&2 2>&3)

  [[ -z "$LANG" ]] && exit 0
  save_lang "$LANG"
fi

# =========================
# Texts
# =========================
if [[ "$LANG" == "PL" ]]; then
  TXT_IFACE="Wybierz interfejs:"
  TXT_OPTION="Wybierz opcję:"
  TXT_RANDOM="Losowy MAC"
  TXT_VENDOR="MAC producenta"
  TXT_RESET="Przywróć oryginalny MAC"
  TXT_VENDOR_CHOOSE="Wybierz producenta:"
  TXT_SUCCESS="✅ Adres MAC został zmieniony pomyślnie"
  TXT_FAIL="❌ Nie udało się zmienić adresu MAC"
else
  TXT_IFACE="Select interface:"
  TXT_OPTION="Choose option:"
  TXT_RANDOM="Random MAC"
  TXT_VENDOR="Vendor MAC"
  TXT_RESET="Restore original MAC"
  TXT_VENDOR_CHOOSE="Choose vendor:"
  TXT_SUCCESS="✅ MAC address changed successfully"
  TXT_FAIL="❌ Failed to change MAC address"
fi

# =========================
# Vendors
# =========================
declare -A VENDORS=(
  ["Apple"]="00:1C:B3"
  ["Samsung"]="FC:C2:DE"
  ["Intel"]="3C:FD:FE"
  ["Cisco"]="00:1B:54"
  ["Huawei"]="28:6E:D4"
  ["Xiaomi"]="64:CC:2E"
  ["Dell"]="F8:BC:12"
  ["HP"]="3C:D9:2B"
  ["Lenovo"]="00:59:07"
  ["ASUS"]="2C:F0:5D"
)

# =========================
# Interface selection
# =========================
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)

IFACE=$(whiptail --title "$APP_NAME" \
--menu "$TXT_IFACE" 15 60 6 \
$(for i in $INTERFACES; do echo "$i $i"; done) \
3>&1 1>&2 2>&3)

[[ -z "$IFACE" ]] && exit 0

OPTION=$(whiptail --title "$APP_NAME" \
--menu "$TXT_OPTION" 15 60 4 \
"1" "$TXT_RANDOM" \
"2" "$TXT_VENDOR" \
"3" "$TXT_RESET" \
3>&1 1>&2 2>&3)

[[ -z "$OPTION" ]] && exit 0

ip link set "$IFACE" down
SUCCESS=true

case $OPTION in
  1) macchanger -r "$IFACE" || SUCCESS=false ;;
  2)
    VENDOR=$(whiptail --title "$APP_NAME" \
    --menu "$TXT_VENDOR_CHOOSE" 20 60 10 \
    $(for v in "${!VENDORS[@]}"; do echo "$v $v"; done) \
    3>&1 1>&2 2>&3)

    [[ -z "$VENDOR" ]] && exit 0
    OUI=${VENDORS[$VENDOR]}
    RAND=$(openssl rand -hex 3 | sed 's/\(..\)/:\1/g')
    macchanger -m "$OUI$RAND" "$IFACE" || SUCCESS=false
    ;;
  3) macchanger -p "$IFACE" || SUCCESS=false ;;
esac

ip link set "$IFACE" up

if [[ "$SUCCESS" == true ]]; then
  MSG="$TXT_SUCCESS"
else
  MSG="$TXT_FAIL"
fi

(macchanger -s "$IFACE"; echo; echo "$MSG") | \
whiptail --title "$APP_NAME" --textbox /dev/stdin 15 60
